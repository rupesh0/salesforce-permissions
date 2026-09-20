public with sharing class ProfileMigrationController {
  // ==========================================
  // DTO Definitions
  // ==========================================

  public class ProfileSummaryDTO implements Comparable {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String licenseName;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public Integer activeUserCount;
    @AuraEnabled
    public Integer totalUserCount;
    @AuraEnabled
    public Boolean isCustom;

    public Integer compareTo(Object compareTo) {
      ProfileSummaryDTO other = (ProfileSummaryDTO) compareTo;
      if (this.name == null)
        return -1;
      if (other.name == null)
        return 1;
      return this.name.toLowerCase().compareTo(other.name.toLowerCase());
    }
  }

  public class ObjectPermDTO implements Comparable {
    @AuraEnabled
    public String objectName;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public Boolean permissionsRead;
    @AuraEnabled
    public Boolean permissionsCreate;
    @AuraEnabled
    public Boolean permissionsEdit;
    @AuraEnabled
    public Boolean permissionsDelete;
    @AuraEnabled
    public Boolean permissionsViewAllRecords;
    @AuraEnabled
    public Boolean permissionsModifyAllRecords;

    public Integer compareTo(Object compareTo) {
      ObjectPermDTO other = (ObjectPermDTO) compareTo;
      if (this.objectName == null)
        return -1;
      if (other.objectName == null)
        return 1;
      return this.objectName
        .toLowerCase()
        .compareTo(other.objectName.toLowerCase());
    }
  }

  public class FieldPermDTO implements Comparable {
    @AuraEnabled
    public String objectName;
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public Boolean permissionsRead;
    @AuraEnabled
    public Boolean permissionsEdit;

    public Integer compareTo(Object compareTo) {
      FieldPermDTO other = (FieldPermDTO) compareTo;
      String thisKey = (this.objectName != null ? this.objectName : '') +
        '.' +
        (this.fieldName != null ? this.fieldName : '');
      String otherKey = (other.objectName != null ? other.objectName : '') +
        '.' +
        (other.fieldName != null ? other.fieldName : '');
      return thisKey.toLowerCase().compareTo(otherKey.toLowerCase());
    }
  }

  public class SystemPermDTO implements Comparable {
    @AuraEnabled
    public String apiName;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public Boolean enabled;

    public Integer compareTo(Object compareTo) {
      SystemPermDTO other = (SystemPermDTO) compareTo;
      String thisLabel = this.label != null ? this.label : this.apiName;
      String otherLabel = other.label != null ? other.label : other.apiName;
      return thisLabel.toLowerCase().compareTo(otherLabel.toLowerCase());
    }
  }

  public class ApexClassPermDTO implements Comparable {
    @AuraEnabled
    public Id classId;
    @AuraEnabled
    public String className;
    @AuraEnabled
    public Boolean enabled;

    public Integer compareTo(Object compareTo) {
      ApexClassPermDTO other = (ApexClassPermDTO) compareTo;
      if (this.className == null)
        return -1;
      if (other.className == null)
        return 1;
      return this.className.toLowerCase().compareTo(other.className.toLowerCase());
    }
  }

  public class ProfileAnalysisDTO {
    @AuraEnabled
    public Id profileId;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public Id permissionSetId;
    @AuraEnabled
    public Integer totalObjects;
    @AuraEnabled
    public Integer totalFields;
    @AuraEnabled
    public Integer totalSystemPerms;
    @AuraEnabled
    public Integer totalApexClasses;
    @AuraEnabled
    public Integer assignedActiveUsers;
    @AuraEnabled
    public List<ObjectPermDTO> objectPermissions;
    @AuraEnabled
    public List<FieldPermDTO> fieldPermissions;
    @AuraEnabled
    public List<SystemPermDTO> systemPermissions;
    @AuraEnabled
    public List<ApexClassPermDTO> apexClassPermissions;
  }

  public class MigrationRequestDTO {
    @AuraEnabled
    public Id sourceProfileId;
    @AuraEnabled
    public String targetType; // 'PERMISSION_SET' or 'PERMISSION_SET_GROUP'
    @AuraEnabled
    public String targetName; // API name
    @AuraEnabled
    public String targetLabel; // Label
    @AuraEnabled
    public String description;
    @AuraEnabled
    public Boolean includeObjects;
    @AuraEnabled
    public Boolean includeFields;
    @AuraEnabled
    public Boolean includeSystemPerms;
    @AuraEnabled
    public Boolean includeApexClasses;
    @AuraEnabled
    public List<String> selectedObjects; // Optional subset
  }

  public class MigrationResultDTO {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public Id permissionSetId;
    @AuraEnabled
    public String permissionSetName;
    @AuraEnabled
    public String permissionSetLabel;
    @AuraEnabled
    public Id permissionSetGroupId;
    @AuraEnabled
    public String permissionSetGroupName;
    @AuraEnabled
    public Integer createdObjectPermCount;
    @AuraEnabled
    public Integer createdFieldPermCount;
    @AuraEnabled
    public Integer createdApexClassCount;
    @AuraEnabled
    public Integer appliedSystemPermCount;
    @AuraEnabled
    public List<String> warnings;
    @AuraEnabled
    public String message;
  }

  public class UserMigrationItemDTO implements Comparable {
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public Boolean isActive;
    @AuraEnabled
    public String status; // 'READY', 'ALREADY_ASSIGNED', 'INACTIVE'
    @AuraEnabled
    public Boolean isSelectable;

    public Integer compareTo(Object compareTo) {
      UserMigrationItemDTO other = (UserMigrationItemDTO) compareTo;
      if (this.name == null)
        return -1;
      if (other.name == null)
        return 1;
      return this.name.toLowerCase().compareTo(other.name.toLowerCase());
    }
  }

  public class UserMigrationPreviewDTO {
    @AuraEnabled
    public Id profileId;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public Id targetPermissionSetId;
    @AuraEnabled
    public Integer totalUsers;
    @AuraEnabled
    public Integer toAssignCount;
    @AuraEnabled
    public Integer alreadyAssignedCount;
    @AuraEnabled
    public Integer inactiveCount;
    @AuraEnabled
    public List<UserMigrationItemDTO> users;
  }

  public class UserMigrationExecutionResultDTO {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public Integer totalAttempted;
    @AuraEnabled
    public Integer successCount;
    @AuraEnabled
    public Integer failureCount;
    @AuraEnabled
    public List<Id> createdAssignmentIds;
    @AuraEnabled
    public List<String> errors;
    @AuraEnabled
    public String message;
  }

  public class UserMigrationRollbackResultDTO {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public Integer rolledBackCount;
    @AuraEnabled
    public String message;
  }

  // ==========================================
  // Controller Endpoints
  // ==========================================

  /**
   * Discovers all profiles in the org with license details and user counts.
   */
  @AuraEnabled(cacheable=true)
  public static List<ProfileSummaryDTO> getMigratableProfiles() {
    try {
      // 1. Fetch profiles
      List<Profile> profiles = [
        SELECT Id, Name, Description, UserLicense.Name
        FROM Profile
        ORDER BY Name
      ];

      // 2. Count active and inactive users per profile
      Map<Id, Integer> activeCountMap = new Map<Id, Integer>();
      Map<Id, Integer> totalCountMap = new Map<Id, Integer>();

      for (AggregateResult ar : [
        SELECT ProfileId, IsActive, COUNT(Id) cnt
        FROM User
        WHERE ProfileId != NULL
        GROUP BY ProfileId, IsActive
      ]) {
        Id profId = (Id) ar.get('ProfileId');
        Boolean isActive = (Boolean) ar.get('IsActive');
        Integer count = ((Decimal) ar.get('cnt')).intValue();

        Integer tot = totalCountMap.containsKey(profId)
          ? totalCountMap.get(profId)
          : 0;
        totalCountMap.put(profId, tot + count);

        if (isActive) {
          Integer act = activeCountMap.containsKey(profId)
            ? activeCountMap.get(profId)
            : 0;
          activeCountMap.put(profId, act + count);
        }
      }

      List<ProfileSummaryDTO> results = new List<ProfileSummaryDTO>();
      for (Profile p : profiles) {
        ProfileSummaryDTO dto = new ProfileSummaryDTO();
        dto.id = p.Id;
        dto.name = p.Name;
        dto.licenseName = p.UserLicense != null
          ? p.UserLicense.Name
          : 'Standard';
        dto.description = p.Description != null ? p.Description : '';
        dto.activeUserCount = activeCountMap.containsKey(p.Id)
          ? activeCountMap.get(p.Id)
          : 0;
        dto.totalUserCount = totalCountMap.containsKey(p.Id)
          ? totalCountMap.get(p.Id)
          : 0;
        // Standard Salesforce convention: profile names with custom namespaces or standard prefixes
        dto.isCustom = !isStandardProfile(p.Name);
        results.add(dto);
      }

      results.sort();
      return results;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to retrieve migratable profiles: ' + e.getMessage()
      );
    }
  }

  /**
   * Deconstructs a profile's underlying PermissionSet into its component capabilities.
   */
  @AuraEnabled(cacheable=true)
  public static ProfileAnalysisDTO analyzeProfilePermissions(Id profileId) {
    if (profileId == null) {
      throw new AuraHandledException('Profile ID must not be null.');
    }

    try {
      Profile prof = [SELECT Id, Name FROM Profile WHERE Id = :profileId LIMIT 1];

      // Resolve backing PermissionSet
      List<PermissionSet> psets = [
        SELECT Id
        FROM PermissionSet
        WHERE ProfileId = :profileId AND IsOwnedByProfile = TRUE
        LIMIT 1
      ];

      if (psets.isEmpty()) {
        throw new AuraHandledException(
          'Could not find underlying Permission Set for profile: ' + prof.Name
        );
      }

      Id psId = psets[0].Id;
      ProfileAnalysisDTO dto = new ProfileAnalysisDTO();
      dto.profileId = profileId;
      dto.profileName = prof.Name;
      dto.permissionSetId = psId;

      // 1. Object Permissions
      List<ObjectPermDTO> objPerms = new List<ObjectPermDTO>();
      for (ObjectPermissions op : [
        SELECT
          SobjectType,
          PermissionsRead,
          PermissionsCreate,
          PermissionsEdit,
          PermissionsDelete,
          PermissionsViewAllRecords,
          PermissionsModifyAllRecords
        FROM ObjectPermissions
        WHERE ParentId = :psId
        ORDER BY SobjectType
      ]) {
        ObjectPermDTO opDto = new ObjectPermDTO();
        opDto.objectName = op.SobjectType;
        opDto.label = op.SobjectType;
        opDto.permissionsRead = op.PermissionsRead;
        opDto.permissionsCreate = op.PermissionsCreate;
        opDto.permissionsEdit = op.PermissionsEdit;
        opDto.permissionsDelete = op.PermissionsDelete;
        opDto.permissionsViewAllRecords = op.PermissionsViewAllRecords;
        opDto.permissionsModifyAllRecords = op.PermissionsModifyAllRecords;
        objPerms.add(opDto);
      }
      objPerms.sort();
      dto.objectPermissions = objPerms;
      dto.totalObjects = objPerms.size();

      // 2. Field Permissions
      List<FieldPermDTO> fldPerms = new List<FieldPermDTO>();
      for (FieldPermissions fp : [
        SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
        FROM FieldPermissions
        WHERE ParentId = :psId
        ORDER BY SobjectType, Field
        LIMIT 4000
      ]) {
        FieldPermDTO fpDto = new FieldPermDTO();
        fpDto.objectName = fp.SobjectType;
        fpDto.fieldName = fp.Field;
        fpDto.permissionsRead = fp.PermissionsRead;
        fpDto.permissionsEdit = fp.PermissionsEdit;
        fldPerms.add(fpDto);
      }
      fldPerms.sort();
      dto.fieldPermissions = fldPerms;
      dto.totalFields = fldPerms.size();

      // 3. Apex Class Permissions
      List<SetupEntityAccess> seaList = [
        SELECT SetupEntityId
        FROM SetupEntityAccess
        WHERE ParentId = :psId AND SetupEntityType = 'ApexClass'
      ];
      Set<Id> apexClassIds = new Set<Id>();
      for (SetupEntityAccess sea : seaList) {
        apexClassIds.add(sea.SetupEntityId);
      }
      Map<Id, String> classNames = new Map<Id, String>();
      if (!apexClassIds.isEmpty()) {
        for (ApexClass ac : [
          SELECT Id, Name
          FROM ApexClass
          WHERE Id IN :apexClassIds
        ]) {
          classNames.put(ac.Id, ac.Name);
        }
      }
      List<ApexClassPermDTO> apexPerms = new List<ApexClassPermDTO>();
      for (Id acId : apexClassIds) {
        ApexClassPermDTO acDto = new ApexClassPermDTO();
        acDto.classId = acId;
        acDto.className = classNames.containsKey(acId)
          ? classNames.get(acId)
          : String.valueOf(acId);
        acDto.enabled = true;
        apexPerms.add(acDto);
      }
      apexPerms.sort();
      dto.apexClassPermissions = apexPerms;
      dto.totalApexClasses = apexPerms.size();

      // 4. System Permissions
      List<SystemPermDTO> sysPerms = extractSystemPermissions(psId);
      sysPerms.sort();
      dto.systemPermissions = sysPerms;
      dto.totalSystemPerms = sysPerms.size();

      // 5. Active User Count
      dto.assignedActiveUsers = [
        SELECT COUNT()
        FROM User
        WHERE ProfileId = :profileId AND IsActive = TRUE
      ];

      return dto;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to analyze profile permissions: ' + e.getMessage()
      );
    }
  }

  /**
   * Generates a new custom PermissionSet (and optional PSG) cloned from selected profile permissions.
   */
  @AuraEnabled
  public static MigrationResultDTO generatePermissionSet(
    MigrationRequestDTO request
  ) {
    if (request == null) {
      throw new AuraHandledException('Migration request cannot be null.');
    }
    if (request.sourceProfileId == null) {
      throw new AuraHandledException('Source profile ID is required.');
    }
    if (String.isBlank(request.targetName)) {
      throw new AuraHandledException('Target API Name is required.');
    }
    if (String.isBlank(request.targetLabel)) {
      throw new AuraHandledException('Target Label is required.');
    }

    String apiName = request.targetName.trim();
    if (!Pattern.matches('^[a-zA-Z][a-zA-Z0-9_]*$', apiName)) {
      throw new AuraHandledException(
        'API Name must begin with a letter and contain only alphanumeric characters and underscores.'
      );
    }

    // Check for duplicate name
    List<PermissionSet> existingSets = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = :apiName
      LIMIT 1
    ];
    if (!existingSets.isEmpty()) {
      throw new AuraHandledException(
        'A Permission Set with API Name "' +
          apiName +
          '" already exists. Please choose a unique API name.'
      );
    }

    Savepoint sp = Database.setSavepoint();
    MigrationResultDTO result = new MigrationResultDTO();
    result.warnings = new List<String>();

    try {
      // 1. Resolve source profile PermissionSet
      List<PermissionSet> sourcePSs = [
        SELECT Id
        FROM PermissionSet
        WHERE
          ProfileId = :request.sourceProfileId
          AND IsOwnedByProfile = TRUE
        LIMIT 1
      ];
      if (sourcePSs.isEmpty()) {
        throw new AuraHandledException(
          'Source Profile backing PermissionSet not found.'
        );
      }
      Id sourcePSId = sourcePSs[0].Id;

      // 2. Insert target Permission Set
      PermissionSet newPS = new PermissionSet(
        Name = apiName,
        Label = request.targetLabel.trim(),
        Description = String.isNotBlank(request.description)
          ? request.description.trim()
          : 'Migrated from profile on ' + Date.today().format()
      );
      insert newPS;
      result.permissionSetId = newPS.Id;
      result.permissionSetName = newPS.Name;
      result.permissionSetLabel = newPS.Label;

      Set<String> targetObjectFilter = new Set<String>();
      if (request.selectedObjects != null && !request.selectedObjects.isEmpty()) {
        for (String objName : request.selectedObjects) {
          if (String.isNotBlank(objName)) {
            targetObjectFilter.add(objName.trim());
          }
        }
      }

      // 3. Clone Object Permissions
      Integer objCount = 0;
      Set<String> copiedObjects = new Set<String>();
      if (request.includeObjects == true) {
        List<ObjectPermissions> sourceOps = [
          SELECT
            SobjectType,
            PermissionsRead,
            PermissionsCreate,
            PermissionsEdit,
            PermissionsDelete,
            PermissionsViewAllRecords,
            PermissionsModifyAllRecords
          FROM ObjectPermissions
          WHERE ParentId = :sourcePSId
        ];

        List<ObjectPermissions> newOps = new List<ObjectPermissions>();
        for (ObjectPermissions op : sourceOps) {
          if (
            targetObjectFilter.isEmpty() ||
            targetObjectFilter.contains(op.SobjectType)
          ) {
            newOps.add(
              new ObjectPermissions(
                ParentId = newPS.Id,
                SobjectType = op.SobjectType,
                PermissionsRead = op.PermissionsRead,
                PermissionsCreate = op.PermissionsCreate,
                PermissionsEdit = op.PermissionsEdit,
                PermissionsDelete = op.PermissionsDelete,
                PermissionsViewAllRecords = op.PermissionsViewAllRecords,
                PermissionsModifyAllRecords = op.PermissionsModifyAllRecords
              )
            );
            copiedObjects.add(op.SobjectType);
          }
        }
        if (!newOps.isEmpty()) {
          insert newOps;
          objCount = newOps.size();
        }
      }
      result.createdObjectPermCount = objCount;

      // 4. Clone Field Permissions
      Integer fldCount = 0;
      if (request.includeFields == true) {
        List<FieldPermissions> sourceFps = [
          SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
          FROM FieldPermissions
          WHERE ParentId = :sourcePSId
          LIMIT 4000
        ];

        List<FieldPermissions> newFps = new List<FieldPermissions>();
        for (FieldPermissions fp : sourceFps) {
          // If object filtering was active, ensure field belongs to an included object
          if (
            copiedObjects.isEmpty() ||
            copiedObjects.contains(fp.SobjectType)
          ) {
            newFps.add(
              new FieldPermissions(
                ParentId = newPS.Id,
                SobjectType = fp.SobjectType,
                Field = fp.Field,
                PermissionsRead = fp.PermissionsRead,
                PermissionsEdit = fp.PermissionsEdit
              )
            );
          }
        }
        if (!newFps.isEmpty()) {
          Database.SaveResult[] srList = Database.insert(newFps, false);
          for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
              fldCount++;
            }
          }
        }
      }
      result.createdFieldPermCount = fldCount;

      // 5. Clone SetupEntityAccess (Apex Classes)
      Integer apexCount = 0;
      if (request.includeApexClasses == true) {
        List<SetupEntityAccess> sourceSeas = [
          SELECT SetupEntityId, SetupEntityType
          FROM SetupEntityAccess
          WHERE ParentId = :sourcePSId AND SetupEntityType = 'ApexClass'
        ];
        List<SetupEntityAccess> newSeas = new List<SetupEntityAccess>();
        for (SetupEntityAccess sea : sourceSeas) {
          newSeas.add(
            new SetupEntityAccess(
              ParentId = newPS.Id,
              SetupEntityId = sea.SetupEntityId
            )
          );
        }
        if (!newSeas.isEmpty()) {
          Database.SaveResult[] srList = Database.insert(newSeas, false);
          for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
              apexCount++;
            }
          }
        }
      }
      result.createdApexClassCount = apexCount;

      // 6. Apply System Permissions
      Integer sysCount = 0;
      if (request.includeSystemPerms == true) {
        sysCount = applySystemPermissions(sourcePSId, newPS.Id, result.warnings);
      }
      result.appliedSystemPermCount = sysCount;

      // 7. Optional Permission Set Group Generation
      if (request.targetType == 'PERMISSION_SET_GROUP') {
        String psgDevName = apiName + '_PSG';
        PermissionSetGroup psg = new PermissionSetGroup(
          DeveloperName = psgDevName,
          MasterLabel = request.targetLabel.trim() + ' (Group)',
          Description = 'Bundled group generated from ' + request.targetLabel
        );
        insert psg;
        result.permissionSetGroupId = psg.Id;
        result.permissionSetGroupName = psg.DeveloperName;

        PermissionSetGroupComponent psgc = new PermissionSetGroupComponent(
          PermissionSetGroupId = psg.Id,
          PermissionSetId = newPS.Id
        );
        insert psgc;
      }

      result.success = true;
      result.message =
        'Successfully generated Permission Set "' +
        newPS.Label +
        '" (' +
        newPS.Name +
        ') with ' +
        objCount +
        ' Objects, ' +
        fldCount +
        ' Fields, ' +
        apexCount +
        ' Apex Classes, and ' +
        sysCount +
        ' System Permissions.';

      return result;
    } catch (Exception e) {
      Database.rollback(sp);
      throw new AuraHandledException(
        'Failed to generate Permission Set: ' + e.getMessage()
      );
    }
  }

  /**
   * Previews user reassignment impact (Dry-run simulation).
   */
  @AuraEnabled
  public static UserMigrationPreviewDTO previewUserMigration(
    Id profileId,
    Id targetPermissionSetId,
    Id targetPsgId
  ) {
    if (profileId == null) {
      throw new AuraHandledException('Profile ID is required.');
    }

    try {
      Profile p = [SELECT Id, Name FROM Profile WHERE Id = :profileId LIMIT 1];

      // Query all users on profile
      List<User> users = [
        SELECT Id, Name, Username, Email, IsActive
        FROM User
        WHERE ProfileId = :profileId
        ORDER BY Name
        LIMIT 1000
      ];

      // Query existing assignments for target PermissionSet or PSG
      Set<Id> assignedUserIds = new Set<Id>();
      if (targetPermissionSetId != null) {
        for (PermissionSetAssignment psa : [
          SELECT AssigneeId
          FROM PermissionSetAssignment
          WHERE
            PermissionSetId = :targetPermissionSetId
            AND AssigneeId IN :users
        ]) {
          assignedUserIds.add(psa.AssigneeId);
        }
      }
      if (targetPsgId != null) {
        for (PermissionSetAssignment psa : [
          SELECT AssigneeId
          FROM PermissionSetAssignment
          WHERE
            PermissionSetGroupId = :targetPsgId
            AND AssigneeId IN :users
        ]) {
          assignedUserIds.add(psa.AssigneeId);
        }
      }

      UserMigrationPreviewDTO preview = new UserMigrationPreviewDTO();
      preview.profileId = profileId;
      preview.profileName = p.Name;
      preview.targetPermissionSetId = targetPermissionSetId;
      preview.totalUsers = users.size();
      preview.toAssignCount = 0;
      preview.alreadyAssignedCount = 0;
      preview.inactiveCount = 0;

      List<UserMigrationItemDTO> userDtos = new List<UserMigrationItemDTO>();
      for (User u : users) {
        UserMigrationItemDTO item = new UserMigrationItemDTO();
        item.userId = u.Id;
        item.name = u.Name;
        item.username = u.Username;
        item.email = u.Email;
        item.isActive = u.IsActive;

        if (!u.IsActive) {
          item.status = 'INACTIVE';
          item.isSelectable = false;
          preview.inactiveCount++;
        } else if (assignedUserIds.contains(u.Id)) {
          item.status = 'ALREADY_ASSIGNED';
          item.isSelectable = false;
          preview.alreadyAssignedCount++;
        } else {
          item.status = 'READY';
          item.isSelectable = true;
          preview.toAssignCount++;
        }
        userDtos.add(item);
      }

      userDtos.sort();
      preview.users = userDtos;
      return preview;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to preview user migration: ' + e.getMessage()
      );
    }
  }

  /**
   * Executes bulk user assignment to the newly generated Permission Set or PSG.
   */
  @AuraEnabled
  public static UserMigrationExecutionResultDTO executeUserMigration(
    Id profileId,
    Id targetPermissionSetId,
    Id targetPsgId,
    List<Id> userIds
  ) {
    if (userIds == null || userIds.isEmpty()) {
      throw new AuraHandledException('No user IDs provided for migration.');
    }
    if (targetPermissionSetId == null && targetPsgId == null) {
      throw new AuraHandledException(
        'A target Permission Set or Permission Set Group ID is required.'
      );
    }

    UserMigrationExecutionResultDTO result = new UserMigrationExecutionResultDTO();
    result.totalAttempted = userIds.size();
    result.successCount = 0;
    result.failureCount = 0;
    result.createdAssignmentIds = new List<Id>();
    result.errors = new List<String>();

    List<PermissionSetAssignment> psasToInsert = new List<PermissionSetAssignment>();
    for (Id uId : userIds) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = uId
      );
      if (targetPsgId != null) {
        psa.PermissionSetGroupId = targetPsgId;
      } else {
        psa.PermissionSetId = targetPermissionSetId;
      }
      psasToInsert.add(psa);
    }

    Database.SaveResult[] srList = Database.insert(psasToInsert, false);
    for (Integer i = 0; i < srList.size(); i++) {
      Database.SaveResult sr = srList[i];
      if (sr.isSuccess()) {
        result.successCount++;
        result.createdAssignmentIds.add(sr.getId());
      } else {
        result.failureCount++;
        for (Database.Error err : sr.getErrors()) {
          result.errors.add(
            'User ' + userIds[i] + ' error: ' + err.getMessage()
          );
        }
      }
    }

    result.success = (result.failureCount == 0);
    result.message =
      'User assignment complete. Assigned ' +
      result.successCount +
      ' of ' +
      result.totalAttempted +
      ' users.';

    return result;
  }

  /**
   * 1-Click Rollback safeguard: Deletes newly created user assignments.
   */
  @AuraEnabled
  public static UserMigrationRollbackResultDTO rollbackUserAssignments(
    List<Id> assignmentIds
  ) {
    if (assignmentIds == null || assignmentIds.isEmpty()) {
      throw new AuraHandledException('No assignment IDs provided for rollback.');
    }

    try {
      List<PermissionSetAssignment> psas = [
        SELECT Id
        FROM PermissionSetAssignment
        WHERE Id IN :assignmentIds
      ];
      delete psas;

      UserMigrationRollbackResultDTO res = new UserMigrationRollbackResultDTO();
      res.success = true;
      res.rolledBackCount = psas.size();
      res.message =
        'Rollback successful: ' +
        psas.size() +
        ' Permission Set Assignments removed.';
      return res;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Rollback failed: ' + e.getMessage()
      );
    }
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  private static Boolean isStandardProfile(String profileName) {
    Set<String> standardProfiles = new Set<String>{
      'System Administrator',
      'Standard User',
      'Standard Platform User',
      'Marketing User',
      'Contract Manager',
      'Solution Manager',
      'Read Only',
      'Chatter Free User',
      'Chatter External User',
      'Chatter Moderator User',
      'Analytics Cloud Security User',
      'Analytics Cloud Integration User'
    };
    return standardProfiles.contains(profileName);
  }

  private static List<SystemPermDTO> extractSystemPermissions(Id psId) {
    Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.PermissionSet.fields.getMap();
    List<String> permFieldNames = new List<String>();
    for (String fn : fieldsMap.keySet()) {
      Schema.DescribeFieldResult dfr = fieldsMap.get(fn).getDescribe();
      if (
        fn.startsWith('permissions') &&
        dfr.getType() == Schema.DisplayType.BOOLEAN
      ) {
        permFieldNames.add(dfr.getName());
      }
    }

    String soql =
      'SELECT Id, ' +
      String.join(permFieldNames, ', ') +
      ' FROM PermissionSet WHERE Id = :psId LIMIT 1';
    PermissionSet ps = Database.query(soql);

    List<SystemPermDTO> dtos = new List<SystemPermDTO>();
    for (String fn : permFieldNames) {
      if ((Boolean) ps.get(fn) == true) {
        SystemPermDTO dto = new SystemPermDTO();
        dto.apiName = fn;
        dto.label = fieldsMap.get(fn).getDescribe().getLabel();
        dto.enabled = true;
        dtos.add(dto);
      }
    }
    return dtos;
  }

  private static Integer applySystemPermissions(
    Id sourcePSId,
    Id targetPSId,
    List<String> warnings
  ) {
    Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.PermissionSet.fields.getMap();
    List<String> permFieldNames = new List<String>();
    for (String fn : fieldsMap.keySet()) {
      Schema.DescribeFieldResult dfr = fieldsMap.get(fn).getDescribe();
      if (
        fn.startsWith('permissions') &&
        dfr.getType() == Schema.DisplayType.BOOLEAN &&
        dfr.isCreateable()
      ) {
        permFieldNames.add(dfr.getName());
      }
    }

    String soql =
      'SELECT Id, ' +
      String.join(permFieldNames, ', ') +
      ' FROM PermissionSet WHERE Id = :sourcePSId LIMIT 1';
    PermissionSet sourcePS = Database.query(soql);

    PermissionSet updatePS = new PermissionSet(Id = targetPSId);
    Integer candidateCount = 0;
    for (String fn : permFieldNames) {
      if ((Boolean) sourcePS.get(fn) == true) {
        updatePS.put(fn, true);
        candidateCount++;
      }
    }

    if (candidateCount == 0) {
      return 0;
    }

    try {
      // First attempt: apply all enabled system permissions in single bulk DML
      update updatePS;
      return candidateCount;
    } catch (Exception e) {
      // If composite dependency fails, fallback to curated core system permissions
      warnings.add(
        'Some advanced system permissions had unmet metadata dependencies and were safely skipped: ' +
        e.getMessage()
      );

      List<String> corePerms = new List<String>{
        'PermissionsApiEnabled',
        'PermissionsViewSetup',
        'PermissionsAuthorApex',
        'PermissionsCustomizeApplication',
        'PermissionsViewAllData',
        'PermissionsModifyAllData',
        'PermissionsManageUsers',
        'PermissionsPasswordNeverExpires',
        'PermissionsExportReport',
        'PermissionsManageRoles',
        'PermissionsManageCustomPermissions'
      };

      PermissionSet fallbackPS = new PermissionSet(Id = targetPSId);
      Integer appliedCore = 0;
      for (String cp : corePerms) {
        if (
          fieldsMap.containsKey(cp.toLowerCase()) &&
          (Boolean) sourcePS.get(cp) == true
        ) {
          try {
            PermissionSet singlePS = new PermissionSet(Id = targetPSId);
            singlePS.put(cp, true);
            update singlePS;
            appliedCore++;
          } catch (Exception ex) {
            // safely ignore individual dependency conflicts
          }
        }
      }
      return appliedCore;
    }
  }
}
