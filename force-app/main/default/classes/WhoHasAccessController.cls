public without sharing class WhoHasAccessController {
  @AuraEnabled(cacheable=true)
  public static List<OptionDTO> getSearchableSObjects() {
    try {
      List<OptionDTO> options = new List<OptionDTO>();
      Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

      for (String apiName : gd.keySet()) {
        Schema.DescribeSObjectResult dsr = gd.get(apiName).getDescribe();
        if (
          dsr.isAccessible() &&
          dsr.isQueryable() &&
          !dsr.isCustomSetting() &&
          !apiName.endsWith('__share') &&
          !apiName.endsWith('__history') &&
          !apiName.endsWith('__feed') &&
          !apiName.endsWith('__changeevent')
        ) {
          options.add(
            new OptionDTO(
              dsr.getName(),
              dsr.getLabel() + ' (' + dsr.getName() + ')'
            )
          );
        }
      }
      options.sort();
      return options;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<OptionDTO> getObjectFields(String sObjectName) {
    if (String.isBlank(sObjectName)) {
      return new List<OptionDTO>();
    }
    try {
      List<OptionDTO> fieldOptions = new List<OptionDTO>();
      Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
      Schema.SObjectType sot = gd.get(sObjectName);
      if (sot == null) {
        return fieldOptions;
      }

      Map<String, Schema.SObjectField> fieldsMap = sot.getDescribe()
        .fields.getMap();
      for (String fieldName : fieldsMap.keySet()) {
        Schema.DescribeFieldResult dfr = fieldsMap.get(fieldName).getDescribe();
        if (dfr.isPermissionable()) {
          String fullName = sObjectName + '.' + dfr.getName();
          fieldOptions.add(
            new OptionDTO(fullName, dfr.getLabel() + ' (' + dfr.getName() + ')')
          );
        }
      }
      fieldOptions.sort();
      return fieldOptions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<OptionDTO> searchApexClasses(String searchTerm) {
    try {
      String searchKey = String.isBlank(searchTerm)
        ? '%'
        : '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';

      List<ApexClass> classes = [
        SELECT Id, Name
        FROM ApexClass
        WHERE
          NamespacePrefix = NULL
          AND Status = 'Active'
          AND Name LIKE :searchKey
        ORDER BY Name
        LIMIT 30
      ];

      List<OptionDTO> options = new List<OptionDTO>();
      for (ApexClass ac : classes) {
        options.add(new OptionDTO(ac.Name, ac.Name));
      }
      return options;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<OptionDTO> searchFlows(String searchTerm) {
    try {
      String searchKey = String.isBlank(searchTerm)
        ? '%'
        : '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';

      List<FlowDefinitionView> flows = [
        SELECT ApiName, Label
        FROM FlowDefinitionView
        WHERE
          IsActive = TRUE
          AND (ApiName LIKE :searchKey
          OR Label LIKE :searchKey)
        ORDER BY Label
        LIMIT 30
      ];

      List<OptionDTO> options = new List<OptionDTO>();
      for (FlowDefinitionView fdv : flows) {
        options.add(
          new OptionDTO(fdv.ApiName, fdv.Label + ' (' + fdv.ApiName + ')')
        );
      }
      return options;
    } catch (Exception e) {
      return new List<OptionDTO>();
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<OptionDTO> getSystemPermissionsList() {
    List<OptionDTO> perms = new List<OptionDTO>();
    perms.add(
      new OptionDTO(
        'PermissionsModifyAllData',
        'Modify All Data (Full Administrative Access)'
      )
    );
    perms.add(
      new OptionDTO(
        'PermissionsViewAllData',
        'View All Data (Full Read Access across all objects)'
      )
    );
    perms.add(
      new OptionDTO(
        'PermissionsAuthorApex',
        'Author Apex (Create & modify Apex code)'
      )
    );
    perms.add(
      new OptionDTO(
        'PermissionsCustomizeApplication',
        'Customize Application (Admin setup configuration)'
      )
    );
    perms.add(
      new OptionDTO(
        'PermissionsManageUsers',
        'Manage Users (Create/reset users & assignments)'
      )
    );
    perms.add(
      new OptionDTO('PermissionsViewSetup', 'View Setup and Configuration')
    );
    perms.add(new OptionDTO('PermissionsExportReports', 'Export Reports'));
    perms.add(new OptionDTO('PermissionsRunReports', 'Run Reports'));
    perms.add(
      new OptionDTO(
        'PermissionsManageCustomPermissions',
        'Manage Custom Permissions'
      )
    );
    perms.add(
      new OptionDTO('PermissionsManageDashboards', 'Manage Dashboards')
    );
    perms.add(
      new OptionDTO('PermissionsPasswordNeverExpires', 'Password Never Expires')
    );
    perms.add(new OptionDTO('PermissionsApiEnabled', 'API Enabled'));
    perms.add(new OptionDTO('PermissionsViewAllRecords', 'View All Records'));
    perms.add(
      new OptionDTO('PermissionsModifyAllRecords', 'Modify All Records')
    );
    perms.add(
      new OptionDTO('PermissionsPrivacyDataAccess', 'Privacy Data Access')
    );
    perms.add(
      new OptionDTO('PermissionsViewEncryptedData', 'View Encrypted Data')
    );
    perms.sort();
    return perms;
  }

  @AuraEnabled
  public static WhoHasAccessResponseDTO getUsersWithAccess(
    String category,
    String targetName,
    String accessType,
    Boolean activeUsersOnly
  ) {
    if (String.isBlank(category) || String.isBlank(targetName)) {
      throw new AuraHandledException('Category and Target Name are required.');
    }

    try {
      WhoHasAccessResponseDTO response = new WhoHasAccessResponseDTO();
      response.category = category;
      response.targetName = targetName;
      response.accessType = String.isNotBlank(accessType)
        ? accessType
        : 'Access';
      response.users = new List<UserAccessResultDTO>();

      // PermissionSet ID -> Grant source explanation
      Map<Id, String> psToSourceReason = new Map<Id, String>();

      // Map to track Profile IDs directly
      Map<Id, String> profileToSourceReason = new Map<Id, String>();

      // Global View/Modify All Data permission sets
      Set<Id> modifyAllDataPSIds = new Set<Id>();
      Set<Id> viewAllDataPSIds = new Set<Id>();
      List<PermissionSet> adminPSList = [
        SELECT
          Id,
          IsOwnedByProfile,
          ProfileId,
          PermissionsModifyAllData,
          PermissionsViewAllData
        FROM PermissionSet
        WHERE PermissionsModifyAllData = TRUE OR PermissionsViewAllData = TRUE
      ];
      for (PermissionSet ps : adminPSList) {
        if (ps.PermissionsModifyAllData) {
          modifyAllDataPSIds.add(ps.Id);
        }
        if (ps.PermissionsViewAllData) {
          viewAllDataPSIds.add(ps.Id);
        }
      }

      // --- 1. Evaluate Category Targets ---

      if (category == 'OBJECT') {
        String query =
          'SELECT ParentId, Parent.IsOwnedByProfile, Parent.ProfileId, Parent.Profile.Name, Parent.Label ' +
          'FROM ObjectPermissions WHERE SObjectType = :targetName';

        if (accessType == 'Create') {
          query += ' AND PermissionsCreate = TRUE';
        } else if (accessType == 'Edit') {
          query += ' AND PermissionsEdit = TRUE';
        } else if (accessType == 'Delete') {
          query += ' AND PermissionsDelete = TRUE';
        } else if (accessType == 'ViewAll') {
          query += ' AND PermissionsViewAllRecords = TRUE';
        } else if (accessType == 'ModifyAll') {
          query += ' AND PermissionsModifyAllRecords = TRUE';
        } else {
          // Default: Read
          query += ' AND PermissionsRead = TRUE';
        }

        List<ObjectPermissions> ops = Database.query(query);
        for (ObjectPermissions op : ops) {
          psToSourceReason.put(op.ParentId, 'Object Permission: ' + accessType);
        }

        // Add System Modify All / View All
        if (accessType == 'Read' || accessType == 'ViewAll') {
          for (Id psId : viewAllDataPSIds) {
            psToSourceReason.put(psId, 'System Permission: View All Data');
          }
          for (Id psId : modifyAllDataPSIds) {
            psToSourceReason.put(psId, 'System Permission: Modify All Data');
          }
        } else if (
          accessType == 'Edit' ||
          accessType == 'Create' ||
          accessType == 'Delete' ||
          accessType == 'ModifyAll'
        ) {
          for (Id psId : modifyAllDataPSIds) {
            psToSourceReason.put(psId, 'System Permission: Modify All Data');
          }
        }
      } else if (category == 'FIELD') {
        String fieldQuery =
          'SELECT ParentId, PermissionsRead, PermissionsEdit ' +
          'FROM FieldPermissions WHERE Field = :targetName';

        if (accessType == 'Edit') {
          fieldQuery += ' AND PermissionsEdit = TRUE';
        } else {
          fieldQuery += ' AND PermissionsRead = TRUE';
        }

        List<FieldPermissions> fps = Database.query(fieldQuery);
        for (FieldPermissions fp : fps) {
          psToSourceReason.put(fp.ParentId, 'Field Permission: ' + accessType);
        }

        // Modify All / View All overrides
        if (accessType == 'Edit') {
          for (Id psId : modifyAllDataPSIds) {
            psToSourceReason.put(psId, 'System Permission: Modify All Data');
          }
        } else {
          for (Id psId : viewAllDataPSIds) {
            psToSourceReason.put(psId, 'System Permission: View All Data');
          }
          for (Id psId : modifyAllDataPSIds) {
            psToSourceReason.put(psId, 'System Permission: Modify All Data');
          }
        }
      } else if (category == 'SYSTEM') {
        String sysPermField = String.escapeSingleQuotes(targetName);
        String sysQuery =
          'SELECT Id, IsOwnedByProfile, ProfileId, Label FROM PermissionSet WHERE ' +
          sysPermField +
          ' = TRUE';
        List<PermissionSet> pss = Database.query(sysQuery);
        for (PermissionSet ps : pss) {
          psToSourceReason.put(ps.Id, 'System Permission: ' + targetName);
        }
      } else if (category == 'APEX') {
        List<ApexClass> matchingClasses = [
          SELECT Id, Name
          FROM ApexClass
          WHERE Name = :targetName
          LIMIT 1
        ];
        if (!matchingClasses.isEmpty()) {
          Id classId = matchingClasses[0].Id;
          List<SetupEntityAccess> seas = [
            SELECT ParentId
            FROM SetupEntityAccess
            WHERE SetupEntityType = 'ApexClass' AND SetupEntityId = :classId
          ];
          for (SetupEntityAccess sea : seas) {
            psToSourceReason.put(
              sea.ParentId,
              'Apex Class Access: ' + targetName
            );
          }
        }
        // Author Apex also grants full class access
        List<PermissionSet> authorApexPSs = [
          SELECT Id
          FROM PermissionSet
          WHERE PermissionsAuthorApex = TRUE
        ];
        for (PermissionSet ps : authorApexPSs) {
          psToSourceReason.put(ps.Id, 'System Permission: Author Apex');
        }
        for (Id psId : modifyAllDataPSIds) {
          psToSourceReason.put(psId, 'System Permission: Modify All Data');
        }
      } else if (category == 'FLOW') {
        List<SetupEntityAccess> seas = [
          SELECT ParentId, SetupEntityId
          FROM SetupEntityAccess
          WHERE SetupEntityType IN ('FlowDefinition', 'FlowDefinitionView')
        ];
        for (SetupEntityAccess sea : seas) {
          psToSourceReason.put(sea.ParentId, 'Flow Access: ' + targetName);
        }
        for (Id psId : modifyAllDataPSIds) {
          psToSourceReason.put(psId, 'System Permission: Modify All Data');
        }
      }

      if (psToSourceReason.isEmpty()) {
        return response;
      }

      // --- 2. Separate Profile vs Regular Permission Sets ---

      Set<Id> matchedPSIds = psToSourceReason.keySet();
      List<PermissionSet> allMatchedPS = [
        SELECT Id, Name, Label, IsOwnedByProfile, ProfileId, Profile.Name
        FROM PermissionSet
        WHERE Id IN :matchedPSIds
      ];

      Map<Id, String> regularPSToLabel = new Map<Id, String>();
      Map<Id, String> profileIdToName = new Map<Id, String>();
      Map<Id, String> profileIdToReason = new Map<Id, String>();

      for (PermissionSet ps : allMatchedPS) {
        String reason = psToSourceReason.get(ps.Id);
        if (ps.IsOwnedByProfile && ps.ProfileId != null) {
          profileIdToName.put(ps.ProfileId, ps.Profile.Name);
          profileIdToReason.put(ps.ProfileId, reason);
        } else {
          regularPSToLabel.put(ps.Id, ps.Label);
        }
      }

      // Map Permission Set Group components
      Map<Id, Set<String>> psToPSGNames = new Map<Id, Set<String>>();
      if (!regularPSToLabel.isEmpty()) {
        List<PermissionSetGroupComponent> psgComponents = [
          SELECT
            PermissionSetGroupId,
            PermissionSetId,
            PermissionSetGroup.MasterLabel
          FROM PermissionSetGroupComponent
          WHERE PermissionSetId IN :regularPSToLabel.keySet()
        ];
        for (PermissionSetGroupComponent psgc : psgComponents) {
          if (!psToPSGNames.containsKey(psgc.PermissionSetId)) {
            psToPSGNames.put(psgc.PermissionSetId, new Set<String>());
          }
          psToPSGNames.get(psgc.PermissionSetId)
            .add(psgc.PermissionSetGroup.MasterLabel);
        }
      }

      // --- 3. Query Users Matching Profiles & Permission Sets ---

      Map<Id, UserAccessResultDTO> userResultsMap = new Map<Id, UserAccessResultDTO>();

      // A: Users by Profile
      if (!profileIdToName.isEmpty()) {
        Set<Id> profileIds = profileIdToName.keySet();
        List<User> profileUsers;
        if (activeUsersOnly == true) {
          profileUsers = [
            SELECT
              Id,
              Name,
              Username,
              ProfileId,
              Profile.Name,
              IsActive,
              UserRole.Name,
              Department,
              Title
            FROM User
            WHERE ProfileId IN :profileIds AND IsActive = TRUE
            LIMIT 2000
          ];
        } else {
          profileUsers = [
            SELECT
              Id,
              Name,
              Username,
              ProfileId,
              Profile.Name,
              IsActive,
              UserRole.Name,
              Department,
              Title
            FROM User
            WHERE ProfileId IN :profileIds
            LIMIT 2000
          ];
        }
        for (User u : profileUsers) {
          UserAccessResultDTO uDTO = getOrCreateUserDTO(userResultsMap, u);
          String profName = u.Profile != null ? u.Profile.Name : 'Profile';
          String reason = profileIdToReason.get(u.ProfileId);
          uDTO.sources.add(new GrantSourceDTO('Profile', profName, reason));
        }
      }

      // B: Users by Permission Set Assignment
      if (!regularPSToLabel.isEmpty()) {
        Set<Id> psIds = regularPSToLabel.keySet();
        List<PermissionSetAssignment> psas;
        if (activeUsersOnly == true) {
          psas = [
            SELECT
              AssigneeId,
              Assignee.Name,
              Assignee.Username,
              Assignee.ProfileId,
              Assignee.Profile.Name,
              Assignee.IsActive,
              Assignee.UserRole.Name,
              Assignee.Department,
              Assignee.Title,
              PermissionSetId,
              PermissionSetGroupId,
              PermissionSetGroup.MasterLabel
            FROM PermissionSetAssignment
            WHERE PermissionSetId IN :psIds AND Assignee.IsActive = TRUE
            LIMIT 3000
          ];
        } else {
          psas = [
            SELECT
              AssigneeId,
              Assignee.Name,
              Assignee.Username,
              Assignee.ProfileId,
              Assignee.Profile.Name,
              Assignee.IsActive,
              Assignee.UserRole.Name,
              Assignee.Department,
              Assignee.Title,
              PermissionSetId,
              PermissionSetGroupId,
              PermissionSetGroup.MasterLabel
            FROM PermissionSetAssignment
            WHERE PermissionSetId IN :psIds
            LIMIT 3000
          ];
        }
        for (PermissionSetAssignment psa : psas) {
          UserAccessResultDTO uDTO = getOrCreateUserDTOFromAssignee(
            userResultsMap,
            psa
          );
          String psLabel = regularPSToLabel.get(psa.PermissionSetId);
          String reason = psToSourceReason.get(psa.PermissionSetId);

          if (
            psa.PermissionSetGroupId != null &&
            psa.PermissionSetGroup != null
          ) {
            uDTO.sources.add(
              new GrantSourceDTO(
                'Permission Set Group',
                psa.PermissionSetGroup.MasterLabel + ' (' + psLabel + ')',
                reason
              )
            );
          } else {
            uDTO.sources.add(
              new GrantSourceDTO('Permission Set', psLabel, reason)
            );
          }
        }
      }

      // --- 4. Finalize User DTOs and Aggregate Metrics ---

      Set<String> uniqueProfiles = new Set<String>();
      Set<String> uniquePermSets = new Set<String>();
      Integer activeCount = 0;

      for (UserAccessResultDTO uDTO : userResultsMap.values()) {
        if (uDTO.isActive) {
          activeCount++;
        }
        uniqueProfiles.add(uDTO.profileName);

        // Deduplicate sources and compile summary
        Set<String> sourceKeys = new Set<String>();
        List<GrantSourceDTO> deduped = new List<GrantSourceDTO>();
        for (GrantSourceDTO gs : uDTO.sources) {
          String key = gs.sourceType + ':' + gs.sourceName;
          if (!sourceKeys.contains(key)) {
            sourceKeys.add(key);
            deduped.add(gs);
            if (gs.sourceType.contains('Permission Set')) {
              uniquePermSets.add(gs.sourceName);
            }
          }
        }
        uDTO.sources = deduped;
        uDTO.totalSourcesCount = deduped.size();

        // Primary source label
        if (!deduped.isEmpty()) {
          uDTO.primarySource =
            deduped[0].sourceType +
            ': ' +
            deduped[0].sourceName;
        }

        response.users.add(uDTO);
      }

      response.users.sort();
      response.totalUsersCount = response.users.size();
      response.activeUsersCount = activeCount;
      response.profilesCount = uniqueProfiles.size();
      response.permissionSetsCount = uniquePermSets.size();

      return response;
    } catch (Exception e) {
      System.debug(
        'Error in getUsersWithAccess: ' +
          e.getMessage() +
          ' | ' +
          e.getStackTraceString()
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  // --- Helper Methods ---

  private static UserAccessResultDTO getOrCreateUserDTO(
    Map<Id, UserAccessResultDTO> userMap,
    User u
  ) {
    if (!userMap.containsKey(u.Id)) {
      UserAccessResultDTO dto = new UserAccessResultDTO();
      dto.userId = u.Id;
      dto.name = u.Name;
      dto.username = u.Username;
      dto.profileName = u.Profile != null ? u.Profile.Name : '';
      dto.isActive = u.IsActive;
      dto.userRole = u.UserRole != null ? u.UserRole.Name : '';
      dto.department = u.Department;
      dto.title = u.Title;
      dto.sources = new List<GrantSourceDTO>();
      userMap.put(u.Id, dto);
    }
    return userMap.get(u.Id);
  }

  private static UserAccessResultDTO getOrCreateUserDTOFromAssignee(
    Map<Id, UserAccessResultDTO> userMap,
    PermissionSetAssignment psa
  ) {
    if (!userMap.containsKey(psa.AssigneeId)) {
      UserAccessResultDTO dto = new UserAccessResultDTO();
      dto.userId = psa.AssigneeId;
      dto.name = psa.Assignee.Name;
      dto.username = psa.Assignee.Username;
      dto.profileName = psa.Assignee.Profile != null
        ? psa.Assignee.Profile.Name
        : '';
      dto.isActive = psa.Assignee.IsActive;
      dto.userRole = psa.Assignee.UserRole != null
        ? psa.Assignee.UserRole.Name
        : '';
      dto.department = psa.Assignee.Department;
      dto.title = psa.Assignee.Title;
      dto.sources = new List<GrantSourceDTO>();
      userMap.put(psa.AssigneeId, dto);
    }
    return userMap.get(psa.AssigneeId);
  }

  // --- DTO Classes ---

  public class OptionDTO implements Comparable {
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;

    public OptionDTO(String value, String label) {
      this.value = value;
      this.label = label;
    }

    public Integer compareTo(Object compareTo) {
      OptionDTO other = (OptionDTO) compareTo;
      if (this.label == null)
        return 1;
      if (other.label == null)
        return -1;
      return this.label.toLowerCase().compareTo(other.label.toLowerCase());
    }
  }

  public class WhoHasAccessResponseDTO {
    @AuraEnabled
    public String category;
    @AuraEnabled
    public String targetName;
    @AuraEnabled
    public String accessType;
    @AuraEnabled
    public Integer totalUsersCount;
    @AuraEnabled
    public Integer activeUsersCount;
    @AuraEnabled
    public Integer profilesCount;
    @AuraEnabled
    public Integer permissionSetsCount;
    @AuraEnabled
    public List<UserAccessResultDTO> users;
  }

  public class UserAccessResultDTO implements Comparable {
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public Boolean isActive;
    @AuraEnabled
    public String userRole;
    @AuraEnabled
    public String department;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String primarySource;
    @AuraEnabled
    public Integer totalSourcesCount;
    @AuraEnabled
    public List<GrantSourceDTO> sources;

    public Integer compareTo(Object compareTo) {
      UserAccessResultDTO other = (UserAccessResultDTO) compareTo;
      if (this.name == null)
        return 1;
      if (other.name == null)
        return -1;
      return this.name.toLowerCase().compareTo(other.name.toLowerCase());
    }
  }

  public class GrantSourceDTO {
    @AuraEnabled
    public String sourceType;
    @AuraEnabled
    public String sourceName;
    @AuraEnabled
    public String reason;

    public GrantSourceDTO(String sourceType, String sourceName, String reason) {
      this.sourceType = sourceType;
      this.sourceName = sourceName;
      this.reason = reason;
    }
  }
}
