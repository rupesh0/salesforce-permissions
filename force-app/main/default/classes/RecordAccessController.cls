public without sharing class RecordAccessController {
  @AuraEnabled(cacheable=true)
  public static List<SObjectOption> getSearchableSObjects() {
    try {
      Object cached = DescribeCacheService.get('SearchableSObjects');
      if (cached != null) {
        return (List<SObjectOption>) cached;
      }

      List<SObjectOption> options = new List<SObjectOption>();
      Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

      for (String apiName : gd.keySet()) {
        Schema.DescribeSObjectResult dsr = gd.get(apiName).getDescribe();
        if (
          dsr.isAccessible() &&
          dsr.isQueryable() &&
          dsr.isSearchable() &&
          !dsr.isCustomSetting() &&
          !apiName.endsWith('__share') &&
          !apiName.endsWith('__history') &&
          !apiName.endsWith('__feed') &&
          !apiName.endsWith('__changeevent')
        ) {
          SObjectOption opt = new SObjectOption();
          opt.apiName = dsr.getName();
          opt.label = dsr.getLabel();
          options.add(opt);
        }
      }

      options.sort();
      DescribeCacheService.put('SearchableSObjects', options, 3600);
      return options;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<RecordOption> searchRecords(
    String sObjectName,
    String searchTerm
  ) {
    if (String.isBlank(sObjectName)) {
      return new List<RecordOption>();
    }
    try {
      Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
      Schema.SObjectType sot = gd.get(sObjectName);
      if (sot == null) {
        return new List<RecordOption>();
      }

      Schema.DescribeSObjectResult dsr = sot.getDescribe();
      String nameField = getNameField(dsr);
      String objName = dsr.getName();
      String objLabel = dsr.getLabel();

      List<RecordOption> records = new List<RecordOption>();

      // Check if searchTerm is a valid Salesforce ID
      String trimmed = String.isNotBlank(searchTerm) ? searchTerm.trim() : '';
      if (isSalesforceId(trimmed)) {
        try {
          String query =
            'SELECT Id, ' +
            nameField +
            ' FROM ' +
            String.escapeSingleQuotes(objName) +
            ' WHERE Id = :trimmed LIMIT 1';
          List<SObject> results = Database.query(query);
          if (!results.isEmpty()) {
            SObject sobj = results[0];
            RecordOption opt = new RecordOption();
            opt.id = sobj.Id;
            opt.name = String.valueOf(sobj.get(nameField));
            opt.sObjectName = objName;
            opt.sObjectLabel = objLabel;
            records.add(opt);
            return records;
          }
        } catch (Exception ex) {
          // Fall through to text search
        }
      }

      String searchKey = String.isBlank(trimmed)
        ? '%'
        : '%' + String.escapeSingleQuotes(trimmed) + '%';
      String query =
        'SELECT Id, ' +
        nameField +
        ' FROM ' +
        String.escapeSingleQuotes(objName) +
        ' WHERE ' +
        nameField +
        ' LIKE :searchKey ORDER BY ' +
        nameField +
        ' LIMIT 25';

      List<SObject> queryResults = Database.query(query);
      for (SObject sobj : queryResults) {
        RecordOption opt = new RecordOption();
        opt.id = sobj.Id;
        opt.name = String.valueOf(sobj.get(nameField));
        opt.sObjectName = objName;
        opt.sObjectLabel = objLabel;
        records.add(opt);
      }
      return records;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<UserOption> searchUsers(String searchTerm) {
    try {
      String searchKey = String.isBlank(searchTerm)
        ? '%'
        : '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';

      List<User> users = [
        SELECT Id, Name, Username, Profile.Name
        FROM User
        WHERE
          IsActive = TRUE
          AND (Name LIKE :searchKey
          OR Username LIKE :searchKey)
        ORDER BY Name
        LIMIT 25
      ];

      List<UserOption> options = new List<UserOption>();
      for (User u : users) {
        UserOption opt = new UserOption();
        opt.id = u.Id;
        opt.name = u.Name;
        opt.username = u.Username;
        opt.profileName = u.Profile != null ? u.Profile.Name : '';
        options.add(opt);
      }
      return options;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static RecordAccessMatrixDTO checkRecordAccess(
    List<Id> recordIds,
    List<Id> userIds
  ) {
    if (
      recordIds == null ||
      recordIds.isEmpty() ||
      userIds == null ||
      userIds.isEmpty()
    ) {
      return new RecordAccessMatrixDTO();
    }
    try {
      RecordAccessMatrixDTO result = new RecordAccessMatrixDTO();
      result.users = new List<UserHeaderDTO>();
      result.rows = new List<RecordRowDTO>();

      // 1. Fetch User details for table headers
      List<User> userList = [
        SELECT Id, Name, Profile.Name
        FROM User
        WHERE Id IN :userIds
        ORDER BY Name
      ];
      for (User u : userList) {
        UserHeaderDTO uh = new UserHeaderDTO();
        uh.userId = u.Id;
        uh.userName = u.Name;
        uh.profileName = u.Profile != null ? u.Profile.Name : '';
        uh.setupUserUrl =
          '/lightning/setup/ManageUsers/page?address=%2F' + u.Id;
        result.users.add(uh);
      }

      // 2. Fetch Record Names and sObjects
      Map<Id, RecordRowDTO> rowMap = new Map<Id, RecordRowDTO>();
      Map<String, Set<Id>> objectToIds = new Map<String, Set<Id>>();

      for (Id rId : recordIds) {
        String sObjName = rId.getSObjectType().getDescribe().getName();
        if (!objectToIds.containsKey(sObjName)) {
          objectToIds.put(sObjName, new Set<Id>());
        }
        objectToIds.get(sObjName).add(rId);

        RecordRowDTO row = new RecordRowDTO();
        row.recordId = rId;
        row.recordName = String.valueOf(rId);
        row.sObjectName = sObjName;
        row.sObjectLabel = rId.getSObjectType().getDescribe().getLabel();
        row.recordUrl = '/lightning/r/' + sObjName + '/' + rId + '/view';
        row.userAccess = new Map<String, AccessDTO>();
        rowMap.put(rId, row);
      }

      for (String sObjName : objectToIds.keySet()) {
        Set<Id> idsForObj = objectToIds.get(sObjName);
        Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe()
          .get(sObjName)
          .getDescribe();
        String nameField = getNameField(dsr);
        try {
          String q =
            'SELECT Id, ' +
            nameField +
            ' FROM ' +
            String.escapeSingleQuotes(sObjName) +
            ' WHERE Id IN :idsForObj';
          for (SObject sobj : Database.query(q)) {
            RecordRowDTO row = rowMap.get(sobj.Id);
            if (row != null) {
              row.recordName = String.valueOf(sobj.get(nameField));
            }
          }
        } catch (Exception ex) {
          // Keep default Id name on describe failure
        }
      }

      // 3. Query UserRecordAccess per user
      for (Id uId : userIds) {
        String uIdStr = String.valueOf(uId);
        List<UserRecordAccess> accessList = [
          SELECT
            RecordId,
            HasReadAccess,
            HasEditAccess,
            HasDeleteAccess,
            MaxAccessLevel
          FROM UserRecordAccess
          WHERE UserId = :uId AND RecordId IN :recordIds
        ];

        Map<Id, UserRecordAccess> accessMap = new Map<Id, UserRecordAccess>();
        for (UserRecordAccess ura : accessList) {
          accessMap.put(ura.RecordId, ura);
        }

        for (Id rId : recordIds) {
          RecordRowDTO row = rowMap.get(rId);
          AccessDTO acc = new AccessDTO();
          UserRecordAccess ura = accessMap.get(rId);
          if (ura != null) {
            acc.hasReadAccess = ura.HasReadAccess;
            acc.hasEditAccess = ura.HasEditAccess;
            acc.maxAccessLevel = ura.MaxAccessLevel;
          } else {
            acc.hasReadAccess = false;
            acc.hasEditAccess = false;
            acc.maxAccessLevel = 'None';
          }
          row.userAccess.put(uIdStr, acc);
        }
      }

      for (Id rId : recordIds) {
        result.rows.add(rowMap.get(rId));
      }

      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static RecordSharingExplanationDTO getRecordSharingDetails(
    Id recordId,
    List<Id> userIds
  ) {
    if (recordId == null || userIds == null || userIds.isEmpty()) {
      return new RecordSharingExplanationDTO();
    }
    try {
      RecordSharingExplanationDTO result = new RecordSharingExplanationDTO();
      result.recordId = recordId;
      result.userExplanations = new List<UserSharingDetailDTO>();

      Schema.DescribeSObjectResult dsr = recordId.getSObjectType()
        .getDescribe();
      String sObjName = dsr.getName();
      result.sObjectName = sObjName;
      result.sObjectLabel = dsr.getLabel();

      // 1. Query Record Name & Owner
      String nameField = getNameField(dsr);
      String queryRecord =
        'SELECT Id, OwnerId, ' +
        nameField +
        ' FROM ' +
        String.escapeSingleQuotes(sObjName) +
        ' WHERE Id = :recordId LIMIT 1';
      SObject targetRecord;
      try {
        targetRecord = Database.query(queryRecord);
        result.recordName = String.valueOf(targetRecord.get(nameField));
        result.ownerId = (Id) targetRecord.get('OwnerId');
      } catch (Exception ex) {
        result.recordName = String.valueOf(recordId);
      }

      if (result.ownerId != null) {
        List<User> owners = [
          SELECT Id, Name
          FROM User
          WHERE Id = :result.ownerId
          LIMIT 1
        ];
        result.ownerName = !owners.isEmpty()
          ? owners[0].Name
          : String.valueOf(result.ownerId);
      } else {
        result.ownerName = 'N/A';
      }

      // 2. Query Org-Wide Default (OWD) from EntityDefinition
      String internalOwd = 'Private';
      try {
        List<SObject> eds = Database.query(
          'SELECT QualifiedApiName, InternalSharingModel, ExternalSharingModel FROM EntityDefinition WHERE QualifiedApiName = :sObjName LIMIT 1'
        );
        if (!eds.isEmpty()) {
          internalOwd = (String) eds[0].get('InternalSharingModel');
        }
      } catch (Exception ex) {
        internalOwd = 'Private';
      }
      result.internalSharingModel = internalOwd;

      // 3. Query System Permissions (View All Data / Modify All Data)
      Set<Id> modifyAllDataUsers = new Set<Id>();
      Set<Id> viewAllDataUsers = new Set<Id>();
      List<PermissionSetAssignment> psaList = [
        SELECT
          AssigneeId,
          PermissionSet.PermissionsModifyAllData,
          PermissionSet.PermissionsViewAllData
        FROM PermissionSetAssignment
        WHERE
          AssigneeId IN :userIds
          AND (PermissionSet.PermissionsModifyAllData = TRUE
          OR PermissionSet.PermissionsViewAllData = TRUE)
      ];
      for (PermissionSetAssignment psa : psaList) {
        if (psa.PermissionSet.PermissionsModifyAllData) {
          modifyAllDataUsers.add(psa.AssigneeId);
        }
        if (psa.PermissionSet.PermissionsViewAllData) {
          viewAllDataUsers.add(psa.AssigneeId);
        }
      }

      // 4. Query Object Permissions (View All Records / Modify All Records)
      Set<Id> modifyAllRecordsUsers = new Set<Id>();
      Set<Id> viewAllRecordsUsers = new Set<Id>();
      List<ObjectPermissions> objPerms = [
        SELECT
          ParentId,
          PermissionsModifyAllRecords,
          PermissionsViewAllRecords,
          Parent.IsOwnedByProfile
        FROM ObjectPermissions
        WHERE
          SObjectType = :sObjName
          AND (PermissionsModifyAllRecords = TRUE
          OR PermissionsViewAllRecords = TRUE)
          AND ParentId IN (
            SELECT PermissionSetId
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds
          )
      ];
      Set<Id> permSetIdsWithModifyAll = new Set<Id>();
      Set<Id> permSetIdsWithViewAll = new Set<Id>();
      for (ObjectPermissions op : objPerms) {
        if (op.PermissionsModifyAllRecords) {
          permSetIdsWithModifyAll.add(op.ParentId);
        }
        if (op.PermissionsViewAllRecords) {
          permSetIdsWithViewAll.add(op.ParentId);
        }
      }
      if (
        !permSetIdsWithModifyAll.isEmpty() || !permSetIdsWithViewAll.isEmpty()
      ) {
        List<PermissionSetAssignment> psAssignments = [
          SELECT AssigneeId, PermissionSetId
          FROM PermissionSetAssignment
          WHERE
            AssigneeId IN :userIds
            AND PermissionSetId IN :permSetIdsWithModifyAll
        ];
        for (PermissionSetAssignment psa : psAssignments) {
          modifyAllRecordsUsers.add(psa.AssigneeId);
        }
        List<PermissionSetAssignment> psAssignmentsView = [
          SELECT AssigneeId, PermissionSetId
          FROM PermissionSetAssignment
          WHERE
            AssigneeId IN :userIds
            AND PermissionSetId IN :permSetIdsWithViewAll
        ];
        for (PermissionSetAssignment psa : psAssignmentsView) {
          viewAllRecordsUsers.add(psa.AssigneeId);
        }
      }

      // 5. Query Share records for this record
      String shareTableName = getShareTableName(sObjName);
      List<SObject> shareRecords = new List<SObject>();
      if (
        String.isNotBlank(shareTableName) &&
        Schema.getGlobalDescribe().containsKey(shareTableName.toLowerCase())
      ) {
        String parentField = getShareParentField(sObjName);
        String accessField = getShareAccessLevelField(sObjName);
        try {
          String qShare =
            'SELECT Id, ' +
            parentField +
            ', UserOrGroupId, ' +
            accessField +
            ', RowCause FROM ' +
            shareTableName +
            ' WHERE ' +
            parentField +
            ' = :recordId';
          shareRecords = Database.query(qShare);
        } catch (Exception ex) {
          // Share table query may fail on certain special objects
        }
      }

      // 6. Map Group memberships for any group share
      Set<Id> groupIdsInShares = new Set<Id>();
      for (SObject sh : shareRecords) {
        Id ugId = (Id) sh.get('UserOrGroupId');
        if (ugId != null && String.valueOf(ugId).startsWith('00G')) {
          groupIdsInShares.add(ugId);
        }
      }

      Map<Id, Group> groupMap = new Map<Id, Group>();
      Map<Id, Set<Id>> userToMemberGroups = new Map<Id, Set<Id>>();
      for (Id uId : userIds) {
        userToMemberGroups.put(uId, new Set<Id>());
      }

      if (!groupIdsInShares.isEmpty()) {
        groupMap = new Map<Id, Group>(
          [
            SELECT Id, Name, DeveloperName, Type, RelatedId
            FROM Group
            WHERE Id IN :groupIdsInShares
          ]
        );

        // Direct and nested group membership
        List<GroupMember> gms = [
          SELECT GroupId, UserOrGroupId
          FROM GroupMember
          WHERE GroupId IN :groupIdsInShares AND UserOrGroupId IN :userIds
        ];
        for (GroupMember gm : gms) {
          if (userToMemberGroups.containsKey(gm.UserOrGroupId)) {
            userToMemberGroups.get(gm.UserOrGroupId).add(gm.GroupId);
          }
        }

        // Roles in groups
        Map<Id, User> userRoleMap = new Map<Id, User>(
          [SELECT Id, UserRoleId FROM User WHERE Id IN :userIds]
        );
        for (User u : userRoleMap.values()) {
          if (u.UserRoleId != null) {
            for (Group grp : groupMap.values()) {
              if (grp.Type == 'Role' && grp.RelatedId == u.UserRoleId) {
                userToMemberGroups.get(u.Id).add(grp.Id);
              }
            }
          }
        }
      }

      // 7. Query UserRecordAccess for overall access levels
      Map<Id, UserRecordAccess> uraMap = new Map<Id, UserRecordAccess>();
      for (Id uId : userIds) {
        List<UserRecordAccess> urasList = [
          SELECT
            RecordId,
            HasReadAccess,
            HasEditAccess,
            HasDeleteAccess,
            MaxAccessLevel
          FROM UserRecordAccess
          WHERE UserId = :uId AND RecordId = :recordId
          LIMIT 1
        ];
        if (!urasList.isEmpty()) {
          uraMap.put(uId, urasList[0]);
        }
      }

      // 8. Compile detailed explanation for each user
      List<User> targetUsers = [
        SELECT Id, Name, Profile.Name, UserRoleId, UserRole.Name
        FROM User
        WHERE Id IN :userIds
        ORDER BY Name
      ];

      for (User u : targetUsers) {
        UserSharingDetailDTO userDetail = new UserSharingDetailDTO();
        userDetail.userId = u.Id;
        userDetail.userName = u.Name;
        userDetail.profileName = u.Profile != null ? u.Profile.Name : '';
        userDetail.setupUserUrl =
          '/lightning/setup/ManageUsers/page?address=%2F' + u.Id;
        userDetail.recordUrl =
          '/lightning/r/' +
          sObjName +
          '/' +
          recordId +
          '/view';
        userDetail.reasons = new List<SharingReasonDTO>();

        UserRecordAccess ura = uraMap.get(u.Id);
        Boolean hasRead = ura != null && ura.HasReadAccess;
        Boolean hasEdit = ura != null && ura.HasEditAccess;

        if (hasEdit) {
          userDetail.overallAccess = 'Read/Write';
        } else if (hasRead) {
          userDetail.overallAccess = 'Read Only';
        } else {
          userDetail.overallAccess = 'No Access';
        }

        // Reason A: Record Ownership
        if (result.ownerId != null && result.ownerId == u.Id) {
          userDetail.overallAccess = 'Full Access (Owner)';
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Record Owner',
              'Full Access',
              'User is the record owner.'
            )
          );
        }

        // Reason B: System Permissions
        if (modifyAllDataUsers.contains(u.Id)) {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'System Permission',
              'Full Access',
              'User has "Modify All Data" system permission.'
            )
          );
        } else if (viewAllDataUsers.contains(u.Id)) {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'System Permission',
              'Read Only',
              'User has "View All Data" system permission.'
            )
          );
        }

        // Reason C: Object Permissions
        if (modifyAllRecordsUsers.contains(u.Id)) {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Object Permission',
              'Read/Write',
              'User has "Modify All Records" permission on ' + sObjName + '.'
            )
          );
        } else if (viewAllRecordsUsers.contains(u.Id)) {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Object Permission',
              'Read Only',
              'User has "View All Records" permission on ' + sObjName + '.'
            )
          );
        }

        // Reason D: Organization-Wide Default (OWD)
        if (internalOwd == 'ReadWrite' || internalOwd == 'Full') {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Organization-Wide Default',
              'Read/Write',
              'Object OWD is Public Read/Write for all internal users.'
            )
          );
        } else if (internalOwd == 'Read') {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Organization-Wide Default',
              'Read Only',
              'Object OWD is Public Read Only for all internal users.'
            )
          );
        } else if (internalOwd == 'ControlledByParent') {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Organization-Wide Default',
              'Controlled by Parent',
              'Object access is inherited from the parent record.'
            )
          );
        }

        // Reason E: Explicit Share Records
        String accessField = getShareAccessLevelField(sObjName);
        for (SObject sh : shareRecords) {
          Id ugId = (Id) sh.get('UserOrGroupId');
          String rowCause = (String) sh.get('RowCause');
          String accLevel = (String) sh.get(accessField);

          // Direct User Share
          if (ugId == u.Id) {
            String category = formatRowCauseCategory(rowCause);
            String explanation = formatRowCauseDetail(rowCause, accLevel, null);
            SharingReasonDTO rDto = new SharingReasonDTO(
              category,
              accLevel,
              explanation
            );
            if (rowCause == 'Manual') {
              rDto.isManualShare = true;
              rDto.shareRecordId = sh.Id;
            }
            userDetail.reasons.add(rDto);
          }
          // Shared via Group / Role
          else if (
            userToMemberGroups.get(u.Id) != null &&
            userToMemberGroups.get(u.Id).contains(ugId)
          ) {
            Group grp = groupMap.get(ugId);
            String groupName = grp != null ? grp.Name : 'Group (' + ugId + ')';
            String category = formatRowCauseCategory(rowCause);
            String explanation =
              'Shared via ' +
              (grp != null && grp.Type == 'Role' ? 'Role' : 'Public Group') +
              ' "' +
              groupName +
              '" with ' +
              accLevel +
              ' access.';
            userDetail.reasons.add(
              new SharingReasonDTO(category, accLevel, explanation)
            );
          }
        }

        // Fallback when no specific reasons identified but access is absent
        if (userDetail.reasons.isEmpty() && !hasRead) {
          userDetail.reasons.add(
            new SharingReasonDTO(
              'Private Sharing',
              'None',
              'Object sharing model is Private and no sharing rules, manual shares, or permissions apply to this user.'
            )
          );
        }

        result.userExplanations.add(userDetail);
      }

      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // --- In-App Remediation Actions ---

  @AuraEnabled
  public static RemediationResultDTO grantManualShare(
    String sObjectName,
    Id recordId,
    Id userId,
    String accessLevel
  ) {
    if (
      String.isBlank(sObjectName) ||
      recordId == null ||
      userId == null ||
      String.isBlank(accessLevel)
    ) {
      throw new AuraHandledException(
        'Missing required parameters for manual share.'
      );
    }
    try {
      // 1. Inspect object's OWD
      String internalOwd = 'Private';
      try {
        List<SObject> eds = Database.query(
          'SELECT QualifiedApiName, InternalSharingModel FROM EntityDefinition WHERE QualifiedApiName = :sObjectName LIMIT 1'
        );
        if (!eds.isEmpty()) {
          internalOwd = (String) eds[0].get('InternalSharingModel');
        }
      } catch (Exception ex) {
        internalOwd = 'Private';
      }

      if (internalOwd == 'ReadWrite' || internalOwd == 'Full') {
        return new RemediationResultDTO(
          false,
          'Manual sharing is not applicable because this object has an Org-Wide Default of Public Read/Write.',
          null
        );
      }
      if (internalOwd == 'ControlledByParent') {
        return new RemediationResultDTO(
          false,
          'This object is Controlled by Parent (Master-Detail). Sharing access must be granted directly on the parent record.',
          null
        );
      }

      String shareTableName = getShareTableName(sObjectName);
      Schema.SObjectType sot = Schema.getGlobalDescribe()
        .get(shareTableName.toLowerCase());
      if (sot == null) {
        return new RemediationResultDTO(
          false,
          'Sharing table (' +
            shareTableName +
            ') is not supported or accessible for object ' +
            sObjectName +
            '.',
          null
        );
      }

      String parentField = getShareParentField(sObjectName);
      String accessField = getShareAccessLevelField(sObjectName);

      // Check if an explicit manual share already exists
      String checkQuery =
        'SELECT Id, ' +
        String.escapeSingleQuotes(accessField) +
        ' FROM ' +
        String.escapeSingleQuotes(shareTableName) +
        ' WHERE ' +
        String.escapeSingleQuotes(parentField) +
        ' = :recordId AND UserOrGroupId = :userId AND RowCause = \'Manual\' LIMIT 1';
      List<SObject> existing = Database.query(checkQuery);

      SObject shareObj;
      if (!existing.isEmpty()) {
        shareObj = existing[0];
        shareObj.put(accessField, accessLevel);
        update shareObj;
        return new RemediationResultDTO(
          true,
          'Manual share updated successfully to ' + accessLevel + ' access.',
          String.valueOf(shareObj.Id)
        );
      } else {
        shareObj = sot.newSObject();
        shareObj.put(parentField, recordId);
        shareObj.put('UserOrGroupId', userId);
        shareObj.put(accessField, accessLevel);
        shareObj.put('RowCause', 'Manual');

        if (sObjectName == 'Account') {
          shareObj.put('OpportunityAccessLevel', 'None');
          shareObj.put('CaseAccessLevel', 'None');
        }

        insert shareObj;
        return new RemediationResultDTO(
          true,
          'Manual share granted successfully with ' + accessLevel + ' access.',
          String.valueOf(shareObj.Id)
        );
      }
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to grant manual share: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static RemediationResultDTO revokeManualShare(
    String sObjectName,
    Id recordId,
    Id userId
  ) {
    if (String.isBlank(sObjectName) || recordId == null || userId == null) {
      throw new AuraHandledException(
        'Missing required parameters to revoke share.'
      );
    }
    try {
      String shareTableName = getShareTableName(sObjectName);
      Schema.SObjectType sot = Schema.getGlobalDescribe()
        .get(shareTableName.toLowerCase());
      if (sot == null) {
        return new RemediationResultDTO(
          false,
          'Sharing table (' +
            shareTableName +
            ') is not supported for object ' +
            sObjectName +
            '.',
          null
        );
      }

      String parentField = getShareParentField(sObjectName);
      String checkQuery =
        'SELECT Id FROM ' +
        String.escapeSingleQuotes(shareTableName) +
        ' WHERE ' +
        String.escapeSingleQuotes(parentField) +
        ' = :recordId AND UserOrGroupId = :userId AND RowCause = \'Manual\' LIMIT 1';
      List<SObject> existing = Database.query(checkQuery);

      if (existing.isEmpty()) {
        return new RemediationResultDTO(
          false,
          'No explicit manual share found for this user on this record.',
          null
        );
      }

      delete existing[0];
      return new RemediationResultDTO(
        true,
        'Manual share revoked successfully.',
        String.valueOf(existing[0].Id)
      );
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to revoke manual share: ' + e.getMessage()
      );
    }
  }

  // --- Helper Methods ---

  private static String getNameField(Schema.DescribeSObjectResult dsr) {
    Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
    if (fieldMap.containsKey('Name')) {
      return 'Name';
    }
    if (fieldMap.containsKey('Subject')) {
      return 'Subject';
    }
    if (fieldMap.containsKey('CaseNumber')) {
      return 'CaseNumber';
    }
    if (fieldMap.containsKey('Title')) {
      return 'Title';
    }
    if (fieldMap.containsKey('DeveloperName')) {
      return 'DeveloperName';
    }
    return 'Id';
  }

  private static Boolean isSalesforceId(String str) {
    if (String.isBlank(str)) {
      return false;
    }
    if (str.length() != 15 && str.length() != 18) {
      return false;
    }
    Pattern idPattern = Pattern.compile('^[a-zA-Z0-9]{15}([a-zA-Z0-9]{3})?$');
    return idPattern.matcher(str).matches();
  }

  private static String getShareTableName(String sObjName) {
    if (sObjName.endsWith('__c')) {
      return sObjName.removeEnd('__c') + '__Share';
    }
    return sObjName + 'Share';
  }

  private static String getShareParentField(String sObjName) {
    if (sObjName == 'Account') {
      return 'AccountId';
    }
    if (sObjName == 'Case') {
      return 'CaseId';
    }
    if (sObjName == 'Contact') {
      return 'ContactId';
    }
    if (sObjName == 'Lead') {
      return 'LeadId';
    }
    if (sObjName == 'Opportunity') {
      return 'OpportunityId';
    }
    if (sObjName == 'Campaign') {
      return 'CampaignId';
    }
    return 'ParentId';
  }

  private static String getShareAccessLevelField(String sObjName) {
    if (sObjName == 'Account') {
      return 'AccountAccessLevel';
    }
    if (sObjName == 'Case') {
      return 'CaseAccessLevel';
    }
    if (sObjName == 'Contact') {
      return 'ContactAccessLevel';
    }
    if (sObjName == 'Lead') {
      return 'LeadAccessLevel';
    }
    if (sObjName == 'Opportunity') {
      return 'OpportunityAccessLevel';
    }
    if (sObjName == 'Campaign') {
      return 'CampaignAccessLevel';
    }
    return 'AccessLevel';
  }

  private static String formatRowCauseCategory(String rowCause) {
    if (rowCause == 'Owner') {
      return 'Record Owner';
    }
    if (rowCause == 'Manual') {
      return 'Manual Sharing';
    }
    if (rowCause == 'Rule') {
      return 'Sharing Rule';
    }
    if (rowCause == 'Team') {
      return 'Team Member';
    }
    if (rowCause == 'ImplicitChild' || rowCause == 'ImplicitParent') {
      return 'Implicit Sharing';
    }
    if (
      rowCause == 'Territory' ||
      rowCause == 'TerritoryManual' ||
      rowCause == 'TerritoryRule'
    ) {
      return 'Territory Management';
    }
    return 'Apex Sharing (' + rowCause + ')';
  }

  private static String formatRowCauseDetail(
    String rowCause,
    String accessLevel,
    String groupName
  ) {
    if (rowCause == 'Manual') {
      return 'Direct manual share granted with ' + accessLevel + ' access.';
    }
    if (rowCause == 'Rule') {
      return 'Criteria-based or Owner-based sharing rule granted with ' +
        accessLevel +
        ' access.';
    }
    if (rowCause == 'Team') {
      return 'Member of record team with ' + accessLevel + ' access.';
    }
    if (rowCause == 'ImplicitChild' || rowCause == 'ImplicitParent') {
      return 'Implicit parent/child record relationship with ' +
        accessLevel +
        ' access.';
    }
    return 'Programmatic share (' +
      rowCause +
      ') granted with ' +
      accessLevel +
      ' access.';
  }

  // --- DTO Classes ---

  public class SObjectOption implements Comparable {
    @AuraEnabled
    public String apiName;
    @AuraEnabled
    public String label;

    public Integer compareTo(Object compareTo) {
      SObjectOption other = (SObjectOption) compareTo;
      if (this.label == null) {
        return 1;
      }
      if (other.label == null) {
        return -1;
      }
      return this.label.toLowerCase().compareTo(other.label.toLowerCase());
    }
  }

  public class RecordOption {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String sObjectName;
    @AuraEnabled
    public String sObjectLabel;
  }

  public class UserOption {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String profileName;
  }

  public class RecordAccessMatrixDTO {
    @AuraEnabled
    public List<UserHeaderDTO> users;
    @AuraEnabled
    public List<RecordRowDTO> rows;
  }

  public class UserHeaderDTO {
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String userName;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public String setupUserUrl;
  }

  public class RecordRowDTO {
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String recordName;
    @AuraEnabled
    public String sObjectName;
    @AuraEnabled
    public String sObjectLabel;
    @AuraEnabled
    public String recordUrl;
    @AuraEnabled
    public Map<String, AccessDTO> userAccess;
  }

  public class AccessDTO {
    @AuraEnabled
    public Boolean hasReadAccess;
    @AuraEnabled
    public Boolean hasEditAccess;
    @AuraEnabled
    public String maxAccessLevel;
  }

  public class RecordSharingExplanationDTO {
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String recordName;
    @AuraEnabled
    public String sObjectName;
    @AuraEnabled
    public String sObjectLabel;
    @AuraEnabled
    public Id ownerId;
    @AuraEnabled
    public String ownerName;
    @AuraEnabled
    public String internalSharingModel;
    @AuraEnabled
    public List<UserSharingDetailDTO> userExplanations;
  }

  public class UserSharingDetailDTO {
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String userName;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public String overallAccess;
    @AuraEnabled
    public String setupUserUrl;
    @AuraEnabled
    public String recordUrl;
    @AuraEnabled
    public List<SharingReasonDTO> reasons;
  }

  public class SharingReasonDTO {
    @AuraEnabled
    public String category;
    @AuraEnabled
    public String accessLevel;
    @AuraEnabled
    public String details;
    @AuraEnabled
    public Boolean isManualShare;
    @AuraEnabled
    public Id shareRecordId;

    public SharingReasonDTO(
      String category,
      String accessLevel,
      String details
    ) {
      this.category = category;
      this.accessLevel = accessLevel;
      this.details = details;
      this.isManualShare = false;
    }
  }

  public class RemediationResultDTO {
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public String recordId;

    public RemediationResultDTO(
      Boolean isSuccess,
      String message,
      String recordId
    ) {
      this.isSuccess = isSuccess;
      this.message = message;
      this.recordId = recordId;
    }
  }
}
