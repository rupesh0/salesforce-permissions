public with sharing class SecurityAdvisorController {
  @AuraEnabled(cacheable=true)
  public static HealthSummaryDTO getSecurityHealthSummary() {
    try {
      HealthSummaryDTO summary = new HealthSummaryDTO();

      // 1. Total Active Users
      summary.totalActiveUsers = [
        SELECT COUNT()
        FROM User
        WHERE IsActive = TRUE
      ];

      // 2. Total Custom Permission Sets
      summary.totalCustomPermissionSets = [
        SELECT COUNT()
        FROM PermissionSet
        WHERE IsOwnedByProfile = FALSE
      ];

      // 3. Scan Critical & High Risk Privileges
      summary.criticalFindings = scanCriticalPrivileges();

      // 4. Scan Dormant Permission Sets (0 active user assignments)
      summary.dormantSets = scanDormantPermissionSets();
      summary.dormantPermissionSetsCount = summary.dormantSets.size();

      // 5. Scan Inactive Users Holding Custom Permission Sets
      summary.inactiveAssignments = scanInactiveUserAssignments();
      summary.inactiveUsersWithAssignmentsCount = summary.inactiveAssignments.size();

      // 6. Scan Redundant Assignments (Admin profile users assigned redundant admin sets)
      summary.redundantAssignments = scanRedundantAssignments();
      summary.redundantAssignmentsCount = summary.redundantAssignments.size();

      // Calculate Counts & Severity
      Integer critCount = 0;
      Integer highCount = 0;
      Integer medCount = 0;
      Integer nonAdminPrivilegedUsersCount = 0;

      for (RiskFindingDTO finding : summary.criticalFindings) {
        if (finding.severity == 'Critical') {
          critCount += finding.affectedUsersCount;
        } else if (finding.severity == 'High') {
          highCount += finding.affectedUsersCount;
        } else {
          medCount += finding.affectedUsersCount;
        }
        nonAdminPrivilegedUsersCount += finding.nonAdminUsersCount;
      }
      summary.criticalRisksCount = critCount;
      summary.highRisksCount = highCount;
      summary.mediumRisksCount = medCount;

      // Calculate Overall Health Score (0 - 100)
      Integer score = 100;

      // Penalties:
      // Non-admin users with critical permissions: -15 pts each (up to -40)
      score -= Math.min(40, nonAdminPrivilegedUsersCount * 15);

      // Inactive users holding permission sets: -5 pts each (up to -20)
      score -= Math.min(20, summary.inactiveUsersWithAssignmentsCount * 5);

      // Dormant permission sets: -2 pts per dormant set (up to -20)
      score -= Math.min(20, summary.dormantPermissionSetsCount * 2);

      // Redundant assignments: -2 pts per redundant assignment (up to -15)
      score -= Math.min(15, summary.redundantAssignmentsCount * 2);

      if (score < 0) {
        score = 0;
      }
      summary.overallScore = score;

      if (score >= 80) {
        summary.healthGrade = 'A (Healthy)';
        summary.scoreVariant = 'success';
      } else if (score >= 60) {
        summary.healthGrade = 'B (Good)';
        summary.scoreVariant = 'info';
      } else if (score >= 40) {
        summary.healthGrade = 'C (Needs Attention)';
        summary.scoreVariant = 'warning';
      } else {
        summary.healthGrade = 'F (Critical Risk)';
        summary.scoreVariant = 'error';
      }

      return summary;
    } catch (Exception e) {
      System.debug(
        'Error in getSecurityHealthSummary: ' +
          e.getMessage() +
          ' | ' +
          e.getStackTraceString()
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  // --- Scanners ---

  private static List<RiskFindingDTO> scanCriticalPrivileges() {
    List<RiskFindingDTO> findings = new List<RiskFindingDTO>();

    // Define sensitive permissions to monitor
    Map<String, PermMeta> monitoredPerms = new Map<String, PermMeta>{
      'PermissionsModifyAllData' => new PermMeta(
        'Modify All Data',
        'Critical',
        'Grants universal ability to read, edit, delete, and view all records and bypass sharing rules across the entire org.'
      ),
      'PermissionsViewAllData' => new PermMeta(
        'View All Data',
        'High',
        'Grants universal read-only access to all records across all objects, bypassing private sharing models.'
      ),
      'PermissionsAuthorApex' => new PermMeta(
        'Author Apex',
        'Critical',
        'Allows writing and modifying Apex code, which runs with elevated system privileges.'
      ),
      'PermissionsCustomizeApplication' => new PermMeta(
        'Customize Application',
        'High',
        'Allows modifying object schema, custom fields, page layouts, automation flows, and security settings.'
      ),
      'PermissionsManageUsers' => new PermMeta(
        'Manage Users',
        'Critical',
        'Allows creating, editing, and resetting passwords for users, and assigning profiles and permission sets.'
      ),
      'PermissionsPasswordNeverExpires' => new PermMeta(
        'Password Never Expires',
        'Medium',
        'Exempts assigned users from password expiration policies, increasing brute force risk.'
      ),
      'PermissionsExportReport' => new PermMeta(
        'Export Reports',
        'Medium',
        'Enables bulk export of report data to CSV/Excel, creating potential data exfiltration risk.'
      ),
      'PermissionsApiEnabled' => new PermMeta(
        'API Enabled',
        'Low',
        'Enables programmatic API access via REST/SOAP to query and mutate org data.'
      )
    };

    // Query PermissionSets that have any of these permissions enabled
    List<PermissionSet> permSets = [
      SELECT
        Id,
        Name,
        Label,
        IsOwnedByProfile,
        ProfileId,
        Profile.Name,
        PermissionsModifyAllData,
        PermissionsViewAllData,
        PermissionsAuthorApex,
        PermissionsCustomizeApplication,
        PermissionsManageUsers,
        PermissionsPasswordNeverExpires,
        PermissionsExportReport,
        PermissionsApiEnabled
      FROM PermissionSet
      WHERE
        PermissionsModifyAllData = TRUE
        OR PermissionsViewAllData = TRUE
        OR PermissionsAuthorApex = TRUE
        OR PermissionsCustomizeApplication = TRUE
        OR PermissionsManageUsers = TRUE
        OR PermissionsPasswordNeverExpires = TRUE
        OR PermissionsExportReport = TRUE
        OR PermissionsApiEnabled = TRUE
    ];

    // Build map: Permission field name -> Set of PermissionSet IDs that grant it
    Map<String, Set<Id>> permToPSIds = new Map<String, Set<Id>>();
    Map<Id, PermissionSet> psMap = new Map<Id, PermissionSet>(permSets);

    for (String permField : monitoredPerms.keySet()) {
      permToPSIds.put(permField, new Set<Id>());
    }

    for (PermissionSet ps : permSets) {
      if (ps.PermissionsModifyAllData == true)
        permToPSIds.get('PermissionsModifyAllData').add(ps.Id);
      if (ps.PermissionsViewAllData == true)
        permToPSIds.get('PermissionsViewAllData').add(ps.Id);
      if (ps.PermissionsAuthorApex == true)
        permToPSIds.get('PermissionsAuthorApex').add(ps.Id);
      if (ps.PermissionsCustomizeApplication == true)
        permToPSIds.get('PermissionsCustomizeApplication').add(ps.Id);
      if (ps.PermissionsManageUsers == true)
        permToPSIds.get('PermissionsManageUsers').add(ps.Id);
      if (ps.PermissionsPasswordNeverExpires == true)
        permToPSIds.get('PermissionsPasswordNeverExpires').add(ps.Id);
      if (ps.PermissionsExportReport == true)
        permToPSIds.get('PermissionsExportReport').add(ps.Id);
      if (ps.PermissionsApiEnabled == true)
        permToPSIds.get('PermissionsApiEnabled').add(ps.Id);
    }

    // Collect all relevant Permission Set IDs
    Set<Id> allRelevantPSIds = new Set<Id>();
    for (Set<Id> psIds : permToPSIds.values()) {
      allRelevantPSIds.addAll(psIds);
    }

    // Query active User Assignments for these Permission Sets
    List<PermissionSetAssignment> assignments = [
      SELECT
        AssigneeId,
        Assignee.Name,
        Assignee.Username,
        Assignee.ProfileId,
        Assignee.Profile.Name,
        PermissionSetId
      FROM PermissionSetAssignment
      WHERE PermissionSetId IN :allRelevantPSIds AND Assignee.IsActive = TRUE
      LIMIT 10000
    ];

    // Map: PermissionSetId -> List of Assignees
    Map<Id, List<PermissionSetAssignment>> psToAssignments = new Map<Id, List<PermissionSetAssignment>>();
    for (PermissionSetAssignment psa : assignments) {
      if (!psToAssignments.containsKey(psa.PermissionSetId)) {
        psToAssignments.put(
          psa.PermissionSetId,
          new List<PermissionSetAssignment>()
        );
      }
      psToAssignments.get(psa.PermissionSetId).add(psa);
    }

    // Query Profile-based assignments (Users whose Profile grants the permission)
    Map<Id, Set<Id>> profileToUserIds = new Map<Id, Set<Id>>();
    Map<Id, User> userCache = new Map<Id, User>();

    Set<Id> profileOwnedPSIds = new Set<Id>();
    for (PermissionSet ps : permSets) {
      if (ps.IsOwnedByProfile && ps.ProfileId != null) {
        profileOwnedPSIds.add(ps.ProfileId);
      }
    }

    if (!profileOwnedPSIds.isEmpty()) {
      List<User> profileUsers = [
        SELECT Id, Name, Username, ProfileId, Profile.Name
        FROM User
        WHERE ProfileId IN :profileOwnedPSIds AND IsActive = TRUE
        LIMIT 5000
      ];
      for (User u : profileUsers) {
        userCache.put(u.Id, u);
        if (!profileToUserIds.containsKey(u.ProfileId)) {
          profileToUserIds.put(u.ProfileId, new Set<Id>());
        }
        profileToUserIds.get(u.ProfileId).add(u.Id);
      }
    }

    // Build finding DTOs
    for (String permField : monitoredPerms.keySet()) {
      PermMeta meta = monitoredPerms.get(permField);
      Set<Id> grantingPSIds = permToPSIds.get(permField);

      Map<Id, AffectedUserDTO> userMap = new Map<Id, AffectedUserDTO>();

      for (Id psId : grantingPSIds) {
        PermissionSet ps = psMap.get(psId);

        // A) If owned by profile: add users of that profile
        if (ps.IsOwnedByProfile && ps.ProfileId != null) {
          Set<Id> uIds = profileToUserIds.get(ps.ProfileId);
          if (uIds != null) {
            for (Id uId : uIds) {
              User u = userCache.get(uId);
              if (u != null && !userMap.containsKey(uId)) {
                AffectedUserDTO uDTO = new AffectedUserDTO();
                uDTO.userId = u.Id;
                uDTO.name = u.Name;
                uDTO.username = u.Username;
                uDTO.profileName = u.Profile != null ? u.Profile.Name : '';
                uDTO.isAdminProfile =
                  uDTO.profileName == 'System Administrator';
                uDTO.grantSource = 'Profile: ' + uDTO.profileName;
                userMap.put(u.Id, uDTO);
              }
            }
          }
        } else {
          // B) Regular Permission Set assignments
          List<PermissionSetAssignment> psas = psToAssignments.get(psId);
          if (psas != null) {
            for (PermissionSetAssignment psa : psas) {
              if (!userMap.containsKey(psa.AssigneeId)) {
                AffectedUserDTO uDTO = new AffectedUserDTO();
                uDTO.userId = psa.AssigneeId;
                uDTO.name = psa.Assignee.Name;
                uDTO.username = psa.Assignee.Username;
                uDTO.profileName = psa.Assignee.Profile != null
                  ? psa.Assignee.Profile.Name
                  : '';
                uDTO.isAdminProfile =
                  uDTO.profileName == 'System Administrator';
                uDTO.grantSource = 'Permission Set: ' + ps.Label;
                userMap.put(psa.AssigneeId, uDTO);
              }
            }
          }
        }
      }

      if (!userMap.isEmpty()) {
        RiskFindingDTO finding = new RiskFindingDTO();
        finding.id = permField;
        finding.permissionApiName = permField;
        finding.permissionLabel = meta.label;
        finding.severity = meta.severity;
        finding.description = meta.description;
        finding.affectedUsersCount = userMap.size();

        Integer nonAdminCount = 0;
        List<AffectedUserDTO> usersList = userMap.values();
        usersList.sort();

        for (AffectedUserDTO u : usersList) {
          if (!u.isAdminProfile) {
            nonAdminCount++;
          }
        }
        finding.nonAdminUsersCount = nonAdminCount;
        finding.users = usersList;
        findings.add(finding);
      }
    }

    return findings;
  }

  private static List<DormantSetDTO> scanDormantPermissionSets() {
    List<DormantSetDTO> dormantList = new List<DormantSetDTO>();

    List<PermissionSet> dormantPS = [
      SELECT Id, Name, Label, Description, CreatedDate
      FROM PermissionSet
      WHERE
        IsOwnedByProfile = FALSE
        AND Id NOT IN (
          SELECT PermissionSetId
          FROM PermissionSetAssignment
          WHERE Assignee.IsActive = TRUE
        )
      ORDER BY Label
      LIMIT 200
    ];

    for (PermissionSet ps : dormantPS) {
      DormantSetDTO dto = new DormantSetDTO();
      dto.permissionSetId = ps.Id;
      dto.name = ps.Name;
      dto.label = ps.Label;
      dto.description = ps.Description != null ? ps.Description : '';
      dto.createdDate = ps.CreatedDate;
      dormantList.add(dto);
    }

    return dormantList;
  }

  private static List<InactiveUserAssignmentDTO> scanInactiveUserAssignments() {
    List<InactiveUserAssignmentDTO> inactiveList = new List<InactiveUserAssignmentDTO>();

    List<PermissionSetAssignment> psas = [
      SELECT
        Id,
        AssigneeId,
        Assignee.Name,
        Assignee.Username,
        Assignee.Profile.Name,
        PermissionSetId,
        PermissionSet.Name,
        PermissionSet.Label
      FROM PermissionSetAssignment
      WHERE Assignee.IsActive = FALSE AND PermissionSet.IsOwnedByProfile = FALSE
      ORDER BY Assignee.Name
      LIMIT 200
    ];

    for (PermissionSetAssignment psa : psas) {
      InactiveUserAssignmentDTO dto = new InactiveUserAssignmentDTO();
      dto.assignmentId = psa.Id;
      dto.userId = psa.AssigneeId;
      dto.userFullName = psa.Assignee.Name;
      dto.username = psa.Assignee.Username;
      dto.profileName = psa.Assignee.Profile != null
        ? psa.Assignee.Profile.Name
        : '';
      dto.permissionSetId = psa.PermissionSetId;
      dto.permissionSetName = psa.PermissionSet.Name;
      dto.permissionSetLabel = psa.PermissionSet.Label;
      inactiveList.add(dto);
    }

    return inactiveList;
  }

  private static List<RedundantAssignmentDTO> scanRedundantAssignments() {
    List<RedundantAssignmentDTO> redundantList = new List<RedundantAssignmentDTO>();

    // Identify System Administrator profile users assigned custom permission sets that grant admin permissions
    List<PermissionSetAssignment> psas = [
      SELECT
        Id,
        AssigneeId,
        Assignee.Name,
        Assignee.Profile.Name,
        PermissionSet.Label,
        PermissionSet.PermissionsModifyAllData,
        PermissionSet.PermissionsViewAllData,
        PermissionSet.PermissionsAuthorApex,
        PermissionSet.PermissionsCustomizeApplication
      FROM PermissionSetAssignment
      WHERE
        Assignee.IsActive = TRUE
        AND Assignee.Profile.Name = 'System Administrator'
        AND PermissionSet.IsOwnedByProfile = FALSE
        AND (PermissionSet.PermissionsModifyAllData = TRUE
        OR PermissionSet.PermissionsViewAllData = TRUE
        OR PermissionSet.PermissionsAuthorApex = TRUE
        OR PermissionSet.PermissionsCustomizeApplication = TRUE)
      LIMIT 100
    ];

    for (PermissionSetAssignment psa : psas) {
      List<String> perms = new List<String>();
      if (psa.PermissionSet.PermissionsModifyAllData)
        perms.add('Modify All Data');
      if (psa.PermissionSet.PermissionsViewAllData)
        perms.add('View All Data');
      if (psa.PermissionSet.PermissionsAuthorApex)
        perms.add('Author Apex');
      if (psa.PermissionSet.PermissionsCustomizeApplication)
        perms.add('Customize Application');

      RedundantAssignmentDTO dto = new RedundantAssignmentDTO();
      dto.assignmentId = psa.Id;
      dto.userId = psa.AssigneeId;
      dto.userName = psa.Assignee.Name;
      dto.profileName = psa.Assignee.Profile != null
        ? psa.Assignee.Profile.Name
        : 'System Administrator';
      dto.permissionSetLabel = psa.PermissionSet.Label;
      dto.redundantPermission = String.join(perms, ', ');
      dto.reason = 'Profile already has full administrative access; Permission Set assignment is redundant.';
      redundantList.add(dto);
    }

    return redundantList;
  }

  // --- In-App Remediation Actions ---

  @AuraEnabled
  public static RemediationResultDTO remediateInactiveUserAssignments(
    List<Id> assignmentIds
  ) {
    if (assignmentIds == null || assignmentIds.isEmpty()) {
      throw new AuraHandledException(
        'No assignment IDs provided for remediation.'
      );
    }
    try {
      List<PermissionSetAssignment> toDelete = [
        SELECT Id
        FROM PermissionSetAssignment
        WHERE Id IN :assignmentIds
      ];
      delete toDelete;
      return new RemediationResultDTO(
        true,
        'Successfully removed ' +
          toDelete.size() +
          ' inactive user assignment(s).'
      );
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to remove assignments: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static RemediationResultDTO remediateRedundantAssignment(
    Id assignmentId
  ) {
    if (assignmentId == null) {
      throw new AuraHandledException(
        'No assignment ID provided for remediation.'
      );
    }
    try {
      List<PermissionSetAssignment> toDelete = [
        SELECT Id
        FROM PermissionSetAssignment
        WHERE Id = :assignmentId
        LIMIT 1
      ];
      if (toDelete.isEmpty()) {
        return new RemediationResultDTO(
          false,
          'Assignment not found or already removed.'
        );
      }
      delete toDelete[0];
      return new RemediationResultDTO(
        true,
        'Successfully removed redundant permission set assignment.'
      );
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to remove assignment: ' + e.getMessage()
      );
    }
  }

  // --- Helper Classes & DTOs ---

  private class PermMeta {
    public String label;
    public String severity;
    public String description;
    public PermMeta(String label, String severity, String description) {
      this.label = label;
      this.severity = severity;
      this.description = description;
    }
  }

  public class HealthSummaryDTO {
    @AuraEnabled
    public Integer overallScore;
    @AuraEnabled
    public String healthGrade;
    @AuraEnabled
    public String scoreVariant;
    @AuraEnabled
    public Integer totalActiveUsers;
    @AuraEnabled
    public Integer totalCustomPermissionSets;
    @AuraEnabled
    public Integer criticalRisksCount;
    @AuraEnabled
    public Integer highRisksCount;
    @AuraEnabled
    public Integer mediumRisksCount;
    @AuraEnabled
    public Integer dormantPermissionSetsCount;
    @AuraEnabled
    public Integer inactiveUsersWithAssignmentsCount;
    @AuraEnabled
    public Integer redundantAssignmentsCount;
    @AuraEnabled
    public List<RiskFindingDTO> criticalFindings;
    @AuraEnabled
    public List<DormantSetDTO> dormantSets;
    @AuraEnabled
    public List<InactiveUserAssignmentDTO> inactiveAssignments;
    @AuraEnabled
    public List<RedundantAssignmentDTO> redundantAssignments;
  }

  public class RiskFindingDTO {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String permissionApiName;
    @AuraEnabled
    public String permissionLabel;
    @AuraEnabled
    public String severity;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public Integer affectedUsersCount;
    @AuraEnabled
    public Integer nonAdminUsersCount;
    @AuraEnabled
    public List<AffectedUserDTO> users;
  }

  public class AffectedUserDTO implements Comparable {
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public Boolean isAdminProfile;
    @AuraEnabled
    public String grantSource;

    public Integer compareTo(Object compareTo) {
      AffectedUserDTO other = (AffectedUserDTO) compareTo;
      if (this.name == null)
        return 1;
      if (other.name == null)
        return -1;
      return this.name.toLowerCase().compareTo(other.name.toLowerCase());
    }
  }

  public class DormantSetDTO {
    @AuraEnabled
    public Id permissionSetId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public DateTime createdDate;
  }

  public class InactiveUserAssignmentDTO {
    @AuraEnabled
    public Id assignmentId;
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String userFullName;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public Id permissionSetId;
    @AuraEnabled
    public String permissionSetName;
    @AuraEnabled
    public String permissionSetLabel;
  }

  public class RedundantAssignmentDTO {
    @AuraEnabled
    public Id assignmentId;
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String userName;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public String permissionSetLabel;
    @AuraEnabled
    public String redundantPermission;
    @AuraEnabled
    public String reason;
  }

  public class RemediationResultDTO {
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String message;

    public RemediationResultDTO(Boolean isSuccess, String message) {
      this.isSuccess = isSuccess;
      this.message = message;
    }
  }
}
