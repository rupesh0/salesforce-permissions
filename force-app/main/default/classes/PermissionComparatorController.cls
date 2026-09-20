public with sharing class PermissionComparatorController {
  // --- Entity Discovery ---

  @AuraEnabled(cacheable=true)
  public static List<EntityOptionDTO> searchEntities(
    String entityType,
    String searchTerm
  ) {
    try {
      String searchKey = String.isBlank(searchTerm)
        ? '%'
        : '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
      List<EntityOptionDTO> results = new List<EntityOptionDTO>();

      // 1. Profiles
      if (
        String.isBlank(entityType) ||
        entityType == 'ALL' ||
        entityType == 'PROFILE'
      ) {
        List<Profile> profiles = [
          SELECT Id, Name, Description, UserType
          FROM Profile
          WHERE Name LIKE :searchKey
          ORDER BY Name
          LIMIT 40
        ];
        for (Profile p : profiles) {
          EntityOptionDTO dto = new EntityOptionDTO();
          dto.id = p.Id;
          dto.name = p.Name;
          dto.label = p.Name;
          dto.entityType = 'PROFILE';
          dto.description = p.Description != null
            ? p.Description
            : 'Standard / Custom Profile';
          results.add(dto);
        }
      }

      // 2. Permission Sets
      if (
        String.isBlank(entityType) ||
        entityType == 'ALL' ||
        entityType == 'PERMISSION_SET'
      ) {
        List<PermissionSet> psets = [
          SELECT Id, Name, Label, Description, Type
          FROM PermissionSet
          WHERE
            IsOwnedByProfile = FALSE
            AND Type != 'Group'
            AND (Label LIKE :searchKey
            OR Name LIKE :searchKey)
          ORDER BY Label
          LIMIT 40
        ];
        for (PermissionSet ps : psets) {
          EntityOptionDTO dto = new EntityOptionDTO();
          dto.id = ps.Id;
          dto.name = ps.Name;
          dto.label = ps.Label;
          dto.entityType = 'PERMISSION_SET';
          dto.description = ps.Description != null
            ? ps.Description
            : 'Custom Permission Set';
          results.add(dto);
        }
      }

      // 3. Permission Set Groups
      if (
        String.isBlank(entityType) ||
        entityType == 'ALL' ||
        entityType == 'PERMISSION_SET_GROUP'
      ) {
        List<PermissionSetGroup> psgs = [
          SELECT Id, DeveloperName, MasterLabel, Description, Status
          FROM PermissionSetGroup
          WHERE MasterLabel LIKE :searchKey OR DeveloperName LIKE :searchKey
          ORDER BY MasterLabel
          LIMIT 40
        ];
        for (PermissionSetGroup psg : psgs) {
          EntityOptionDTO dto = new EntityOptionDTO();
          dto.id = psg.Id;
          dto.name = psg.DeveloperName;
          dto.label = psg.MasterLabel;
          dto.entityType = 'PERMISSION_SET_GROUP';
          dto.description = psg.Description != null
            ? psg.Description
            : 'Permission Set Group (' + psg.Status + ')';
          results.add(dto);
        }
      }

      results.sort();
      return results;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // --- Comparison Engine ---

  @AuraEnabled(cacheable=true)
  public static ComparisonResultDTO compareEntities(
    String leftType,
    Id leftId,
    String rightType,
    Id rightId,
    String category
  ) {
    if (leftId == null || rightId == null) {
      throw new AuraHandledException(
        'Both Left and Right entities must be selected for comparison.'
      );
    }
    String compCategory = String.isBlank(category)
      ? 'OBJECT'
      : category.toUpperCase();

    try {
      Id leftPSId = resolvePermissionSetId(leftType, leftId);
      Id rightPSId = resolvePermissionSetId(rightType, rightId);

      ComparisonResultDTO result = new ComparisonResultDTO();
      result.category = compCategory;
      result.leftEntity = getEntityMetadata(leftType, leftId);
      result.rightEntity = getEntityMetadata(rightType, rightId);

      if (compCategory == 'OBJECT') {
        compareObjects(leftPSId, rightPSId, result);
      } else if (compCategory == 'FIELD') {
        compareFields(leftPSId, rightPSId, result);
      } else if (compCategory == 'SYSTEM') {
        compareSystemPermissions(leftPSId, rightPSId, result);
      } else if (compCategory == 'APEX') {
        compareSetupEntities(leftPSId, rightPSId, 'ApexClass', result);
      } else if (compCategory == 'FLOW') {
        compareSetupEntities(leftPSId, rightPSId, 'FlowDefinition', result);
      }

      // Calculate Counters
      Integer ident = 0;
      Integer diff = 0;
      Integer lOnly = 0;
      Integer rOnly = 0;

      for (ComparisonRowDTO row : result.rows) {
        if (row.diffStatus == 'IDENTICAL') {
          ident++;
        } else if (row.diffStatus == 'DIFFERENT') {
          diff++;
        } else if (row.diffStatus == 'LEFT_ONLY') {
          lOnly++;
        } else if (row.diffStatus == 'RIGHT_ONLY') {
          rOnly++;
        }
      }

      result.totalItems = result.rows.size();
      result.identicalCount = ident;
      result.differentCount = diff;
      result.leftOnlyCount = lOnly;
      result.rightOnlyCount = rOnly;

      return result;
    } catch (Exception e) {
      System.debug(
        'Error in compareEntities: ' +
          e.getMessage() +
          ' | ' +
          e.getStackTraceString()
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  // --- PSG & Muting Inspector ---

  @AuraEnabled(cacheable=true)
  public static List<PSGOptionDTO> getPSGList() {
    try {
      List<PermissionSetGroup> psgs = [
        SELECT
          Id,
          DeveloperName,
          MasterLabel,
          Description,
          Status,
          HasActivationRequired
        FROM PermissionSetGroup
        ORDER BY MasterLabel
      ];

      Set<Id> psgIds = new Set<Id>();
      for (PermissionSetGroup psg : psgs) {
        psgIds.add(psg.Id);
      }

      // Query component counts and muting presence
      List<PermissionSetGroupComponent> comps = [
        SELECT PermissionSetGroupId, PermissionSetId
        FROM PermissionSetGroupComponent
        WHERE PermissionSetGroupId IN :psgIds
      ];

      Map<Id, Integer> bundledCounts = new Map<Id, Integer>();
      Map<Id, Boolean> hasMutingMap = new Map<Id, Boolean>();

      for (PermissionSetGroupComponent c : comps) {
        Boolean isMuting = String.valueOf(c.PermissionSetId).startsWith('0QM');
        if (isMuting) {
          hasMutingMap.put(c.PermissionSetGroupId, true);
        } else {
          Integer count = bundledCounts.containsKey(c.PermissionSetGroupId)
            ? bundledCounts.get(c.PermissionSetGroupId)
            : 0;
          bundledCounts.put(c.PermissionSetGroupId, count + 1);
        }
      }

      List<PSGOptionDTO> options = new List<PSGOptionDTO>();
      for (PermissionSetGroup psg : psgs) {
        PSGOptionDTO dto = new PSGOptionDTO();
        dto.id = psg.Id;
        dto.developerName = psg.DeveloperName;
        dto.masterLabel = psg.MasterLabel;
        dto.description = psg.Description != null ? psg.Description : '';
        dto.status = psg.Status;
        dto.hasActivationRequired = psg.HasActivationRequired;
        dto.bundledCount = bundledCounts.containsKey(psg.Id)
          ? bundledCounts.get(psg.Id)
          : 0;
        dto.hasMuting =
          hasMutingMap.containsKey(psg.Id) && hasMutingMap.get(psg.Id);
        options.add(dto);
      }

      return options;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static PSGDetailDTO getPSGDetail(Id psgId) {
    if (psgId == null) {
      throw new AuraHandledException('Permission Set Group ID is required.');
    }

    try {
      List<PermissionSetGroup> psgs = [
        SELECT
          Id,
          DeveloperName,
          MasterLabel,
          Description,
          Status,
          HasActivationRequired
        FROM PermissionSetGroup
        WHERE Id = :psgId
        LIMIT 1
      ];
      if (psgs.isEmpty()) {
        throw new AuraHandledException('Permission Set Group not found.');
      }
      PermissionSetGroup psg = psgs[0];

      PSGDetailDTO detail = new PSGDetailDTO();
      detail.id = psg.Id;
      detail.developerName = psg.DeveloperName;
      detail.masterLabel = psg.MasterLabel;
      detail.description = psg.Description != null ? psg.Description : '';
      detail.status = psg.Status;
      detail.hasActivationRequired = psg.HasActivationRequired;

      // 1. Components
      List<PermissionSetGroupComponent> comps = [
        SELECT
          Id,
          PermissionSetId,
          PermissionSet.Name,
          PermissionSet.Label,
          PermissionSet.Description,
          PermissionSet.Type
        FROM PermissionSetGroupComponent
        WHERE PermissionSetGroupId = :psgId
      ];

      detail.bundledPermissionSets = new List<PSGBundledSetDTO>();
      Id mutingSetId = null;
      Set<Id> bundledPSIds = new Set<Id>();

      for (PermissionSetGroupComponent c : comps) {
        Boolean isMuting = String.valueOf(c.PermissionSetId).startsWith('0QM');
        if (isMuting) {
          mutingSetId = c.PermissionSetId;
          detail.hasMuting = true;
          detail.mutingSetId = c.PermissionSetId;
        } else {
          bundledPSIds.add(c.PermissionSetId);
          PSGBundledSetDTO bDTO = new PSGBundledSetDTO();
          bDTO.id = c.PermissionSetId;
          bDTO.name = c.PermissionSet.Name;
          bDTO.label = c.PermissionSet.Label;
          bDTO.description = c.PermissionSet.Description != null
            ? c.PermissionSet.Description
            : '';
          bDTO.type = c.PermissionSet.Type;
          detail.bundledPermissionSets.add(bDTO);
        }
      }

      // If Muting Set exists, query its details
      if (mutingSetId != null) {
        List<MutingPermissionSet> mpsRecords = [
          SELECT Id, DeveloperName, MasterLabel
          FROM MutingPermissionSet
          WHERE Id = :mutingSetId
          LIMIT 1
        ];
        if (!mpsRecords.isEmpty()) {
          detail.mutingSetLabel = mpsRecords[0].MasterLabel;
          detail.mutingSetName = mpsRecords[0].DeveloperName;
        }
      }

      // 2. Query Effective Group Permission Set
      List<PermissionSet> groupPSList = [
        SELECT Id
        FROM PermissionSet
        WHERE PermissionSetGroupId = :psgId AND Type = 'Group'
        LIMIT 1
      ];

      // 3. Compute Muting Impact on Objects
      detail.mutingImpactRows = calculateObjectMutingImpact(
        bundledPSIds,
        mutingSetId,
        groupPSList.isEmpty() ? null : groupPSList[0].Id
      );

      return detail;
    } catch (Exception e) {
      System.debug(
        'Error in getPSGDetail: ' +
          e.getMessage() +
          ' | ' +
          e.getStackTraceString()
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  // --- Private Helpers ---

  private static Id resolvePermissionSetId(String entityType, Id entityId) {
    if (entityType == 'PROFILE') {
      List<PermissionSet> psets = [
        SELECT Id
        FROM PermissionSet
        WHERE ProfileId = :entityId AND IsOwnedByProfile = TRUE
        LIMIT 1
      ];
      if (psets.isEmpty()) {
        throw new AuraHandledException(
          'Unable to resolve Profile to Permission Set.'
        );
      }
      return psets[0].Id;
    } else if (entityType == 'PERMISSION_SET') {
      return entityId;
    } else if (entityType == 'PERMISSION_SET_GROUP') {
      List<PermissionSet> psets = [
        SELECT Id
        FROM PermissionSet
        WHERE PermissionSetGroupId = :entityId AND Type = 'Group'
        LIMIT 1
      ];
      if (psets.isEmpty()) {
        throw new AuraHandledException(
          'Calculated Permission Set for Group not found.'
        );
      }
      return psets[0].Id;
    }
    return entityId;
  }

  private static EntityOptionDTO getEntityMetadata(
    String entityType,
    Id entityId
  ) {
    EntityOptionDTO dto = new EntityOptionDTO();
    dto.id = entityId;
    dto.entityType = entityType;

    if (entityType == 'PROFILE') {
      List<Profile> profs = [
        SELECT Id, Name, Description
        FROM Profile
        WHERE Id = :entityId
        LIMIT 1
      ];
      if (!profs.isEmpty()) {
        dto.name = profs[0].Name;
        dto.label = profs[0].Name;
        dto.description = profs[0].Description != null
          ? profs[0].Description
          : 'Profile';
      }
    } else if (entityType == 'PERMISSION_SET') {
      List<PermissionSet> psets = [
        SELECT Id, Name, Label, Description
        FROM PermissionSet
        WHERE Id = :entityId
        LIMIT 1
      ];
      if (!psets.isEmpty()) {
        dto.name = psets[0].Name;
        dto.label = psets[0].Label;
        dto.description = psets[0].Description != null
          ? psets[0].Description
          : 'Permission Set';
      }
    } else if (entityType == 'PERMISSION_SET_GROUP') {
      List<PermissionSetGroup> psgs = [
        SELECT Id, DeveloperName, MasterLabel, Description, Status
        FROM PermissionSetGroup
        WHERE Id = :entityId
        LIMIT 1
      ];
      if (!psgs.isEmpty()) {
        dto.name = psgs[0].DeveloperName;
        dto.label = psgs[0].MasterLabel;
        dto.description = psgs[0].Description != null
          ? psgs[0].Description
          : 'Permission Set Group';
      }
    }
    return dto;
  }

  private static void compareObjects(
    Id leftPSId,
    Id rightPSId,
    ComparisonResultDTO result
  ) {
    List<ObjectPermissions> allPerms = [
      SELECT
        ParentId,
        SobjectType,
        PermissionsRead,
        PermissionsCreate,
        PermissionsEdit,
        PermissionsDelete,
        PermissionsViewAllRecords,
        PermissionsModifyAllRecords
      FROM ObjectPermissions
      WHERE ParentId IN (:leftPSId, :rightPSId)
      ORDER BY SobjectType
    ];

    Map<String, ObjectPermissions> leftMap = new Map<String, ObjectPermissions>();
    Map<String, ObjectPermissions> rightMap = new Map<String, ObjectPermissions>();
    Set<String> allObjects = new Set<String>();

    for (ObjectPermissions op : allPerms) {
      allObjects.add(op.SobjectType);
      if (op.ParentId == leftPSId) {
        leftMap.put(op.SobjectType, op);
      } else {
        rightMap.put(op.SobjectType, op);
      }
    }

    List<String> sortedObjects = new List<String>(allObjects);
    sortedObjects.sort();

    List<ComparisonRowDTO> rows = new List<ComparisonRowDTO>();
    for (String objName : sortedObjects) {
      ObjectPermissions l = leftMap.get(objName);
      ObjectPermissions r = rightMap.get(objName);

      ComparisonRowDTO row = new ComparisonRowDTO();
      row.itemKey = objName;
      row.itemLabel = objName;
      row.category = 'OBJECT';

      Map<String, Boolean> lFlags = buildObjFlags(l);
      Map<String, Boolean> rFlags = buildObjFlags(r);
      row.leftFlags = lFlags;
      row.rightFlags = rFlags;

      row.leftAccess = formatObjSummary(lFlags);
      row.rightAccess = formatObjSummary(rFlags);

      // Determine diff status
      if (l == null && r != null) {
        row.diffStatus = 'RIGHT_ONLY';
      } else if (l != null && r == null) {
        row.diffStatus = 'LEFT_ONLY';
      } else if (flagsEqual(lFlags, rFlags)) {
        row.diffStatus = 'IDENTICAL';
      } else {
        row.diffStatus = 'DIFFERENT';
      }

      rows.add(row);
    }
    result.rows = rows;
  }

  private static void compareFields(
    Id leftPSId,
    Id rightPSId,
    ComparisonResultDTO result
  ) {
    List<FieldPermissions> allPerms = [
      SELECT ParentId, SobjectType, Field, PermissionsRead, PermissionsEdit
      FROM FieldPermissions
      WHERE ParentId IN (:leftPSId, :rightPSId)
      ORDER BY SobjectType, Field
      LIMIT 10000
    ];

    Map<String, FieldPermissions> leftMap = new Map<String, FieldPermissions>();
    Map<String, FieldPermissions> rightMap = new Map<String, FieldPermissions>();
    Set<String> allFields = new Set<String>();

    for (FieldPermissions fp : allPerms) {
      allFields.add(fp.Field);
      if (fp.ParentId == leftPSId) {
        leftMap.put(fp.Field, fp);
      } else {
        rightMap.put(fp.Field, fp);
      }
    }

    List<String> sortedFields = new List<String>(allFields);
    sortedFields.sort();

    List<ComparisonRowDTO> rows = new List<ComparisonRowDTO>();
    for (String fldKey : sortedFields) {
      FieldPermissions l = leftMap.get(fldKey);
      FieldPermissions r = rightMap.get(fldKey);

      ComparisonRowDTO row = new ComparisonRowDTO();
      row.itemKey = fldKey;
      row.itemLabel = fldKey;
      row.category = 'FIELD';

      Map<String, Boolean> lFlags = new Map<String, Boolean>{
        'Read' => l != null && l.PermissionsRead,
        'Edit' => l != null && l.PermissionsEdit
      };
      Map<String, Boolean> rFlags = new Map<String, Boolean>{
        'Read' => r != null && r.PermissionsRead,
        'Edit' => r != null && r.PermissionsEdit
      };
      row.leftFlags = lFlags;
      row.rightFlags = rFlags;

      row.leftAccess = formatFieldSummary(lFlags);
      row.rightAccess = formatFieldSummary(rFlags);

      if (l == null && r != null) {
        row.diffStatus = 'RIGHT_ONLY';
      } else if (l != null && r == null) {
        row.diffStatus = 'LEFT_ONLY';
      } else if (flagsEqual(lFlags, rFlags)) {
        row.diffStatus = 'IDENTICAL';
      } else {
        row.diffStatus = 'DIFFERENT';
      }

      rows.add(row);
    }
    result.rows = rows;
  }

  private static void compareSystemPermissions(
    Id leftPSId,
    Id rightPSId,
    ComparisonResultDTO result
  ) {
    Map<String, String> sysPerms = new Map<String, String>{
      'PermissionsModifyAllData' => 'Modify All Data',
      'PermissionsViewAllData' => 'View All Data',
      'PermissionsAuthorApex' => 'Author Apex',
      'PermissionsCustomizeApplication' => 'Customize Application',
      'PermissionsManageUsers' => 'Manage Users',
      'PermissionsPasswordNeverExpires' => 'Password Never Expires',
      'PermissionsExportReport' => 'Export Reports',
      'PermissionsApiEnabled' => 'API Enabled',
      'PermissionsViewSetup' => 'View Setup and Configuration',
      'PermissionsManageCustomPermissions' => 'Manage Custom Permissions',
      'PermissionsManageRoles' => 'Manage Roles',
      'PermissionsManageProfilesPermissionsets' => 'Manage Profiles and Permission Sets'
    };

    List<PermissionSet> psets = [
      SELECT
        Id,
        PermissionsModifyAllData,
        PermissionsViewAllData,
        PermissionsAuthorApex,
        PermissionsCustomizeApplication,
        PermissionsManageUsers,
        PermissionsPasswordNeverExpires,
        PermissionsExportReport,
        PermissionsApiEnabled,
        PermissionsViewSetup,
        PermissionsManageCustomPermissions,
        PermissionsManageRoles,
        PermissionsManageProfilesPermissionsets
      FROM PermissionSet
      WHERE Id IN (:leftPSId, :rightPSId)
    ];

    PermissionSet leftPS = null;
    PermissionSet rightPS = null;
    for (PermissionSet ps : psets) {
      if (ps.Id == leftPSId)
        leftPS = ps;
      if (ps.Id == rightPSId)
        rightPS = ps;
    }

    List<ComparisonRowDTO> rows = new List<ComparisonRowDTO>();
    for (String fieldName : sysPerms.keySet()) {
      Boolean lVal = leftPS != null && (Boolean) leftPS.get(fieldName) == true;
      Boolean rVal =
        rightPS != null &&
        (Boolean) rightPS.get(fieldName) == true;

      ComparisonRowDTO row = new ComparisonRowDTO();
      row.itemKey = fieldName;
      row.itemLabel = sysPerms.get(fieldName);
      row.category = 'SYSTEM';

      row.leftFlags = new Map<String, Boolean>{ 'Enabled' => lVal };
      row.rightFlags = new Map<String, Boolean>{ 'Enabled' => rVal };
      row.leftAccess = lVal ? 'Enabled' : 'Disabled';
      row.rightAccess = rVal ? 'Enabled' : 'Disabled';

      if (lVal == rVal) {
        row.diffStatus = 'IDENTICAL';
      } else if (lVal && !rVal) {
        row.diffStatus = 'LEFT_ONLY';
      } else {
        row.diffStatus = 'RIGHT_ONLY';
      }

      rows.add(row);
    }
    result.rows = rows;
  }

  private static void compareSetupEntities(
    Id leftPSId,
    Id rightPSId,
    String entityType,
    ComparisonResultDTO result
  ) {
    List<SetupEntityAccess> seaList = [
      SELECT ParentId, SetupEntityId
      FROM SetupEntityAccess
      WHERE
        SetupEntityType = :entityType
        AND ParentId IN (:leftPSId, :rightPSId)
    ];

    Set<Id> entityIds = new Set<Id>();
    Set<Id> leftEntities = new Set<Id>();
    Set<Id> rightEntities = new Set<Id>();

    for (SetupEntityAccess sea : seaList) {
      entityIds.add(sea.SetupEntityId);
      if (sea.ParentId == leftPSId) {
        leftEntities.add(sea.SetupEntityId);
      } else {
        rightEntities.add(sea.SetupEntityId);
      }
    }

    Map<Id, String> nameMap = new Map<Id, String>();
    if (entityType == 'ApexClass') {
      for (ApexClass ac : [
        SELECT Id, Name
        FROM ApexClass
        WHERE Id IN :entityIds
      ]) {
        nameMap.put(ac.Id, ac.Name);
      }
    } else {
      // FlowDefinition or generic
      for (Id eid : entityIds) {
        nameMap.put(eid, String.valueOf(eid));
      }
    }

    List<ComparisonRowDTO> rows = new List<ComparisonRowDTO>();
    for (Id eid : entityIds) {
      String label = nameMap.containsKey(eid)
        ? nameMap.get(eid)
        : String.valueOf(eid);
      Boolean lVal = leftEntities.contains(eid);
      Boolean rVal = rightEntities.contains(eid);

      ComparisonRowDTO row = new ComparisonRowDTO();
      row.itemKey = String.valueOf(eid);
      row.itemLabel = label;
      row.category = entityType == 'ApexClass' ? 'APEX' : 'FLOW';

      row.leftFlags = new Map<String, Boolean>{ 'Enabled' => lVal };
      row.rightFlags = new Map<String, Boolean>{ 'Enabled' => rVal };
      row.leftAccess = lVal ? 'Enabled' : 'No Access';
      row.rightAccess = rVal ? 'Enabled' : 'No Access';

      if (lVal == rVal) {
        row.diffStatus = 'IDENTICAL';
      } else if (lVal && !rVal) {
        row.diffStatus = 'LEFT_ONLY';
      } else {
        row.diffStatus = 'RIGHT_ONLY';
      }

      rows.add(row);
    }
    result.rows = rows;
  }

  private static List<PSGMutingImpactDTO> calculateObjectMutingImpact(
    Set<Id> bundledPSIds,
    Id mutingSetId,
    Id groupPSId
  ) {
    List<PSGMutingImpactDTO> impactRows = new List<PSGMutingImpactDTO>();
    if (bundledPSIds.isEmpty()) {
      return impactRows;
    }

    // 1. Bundled Permissions
    List<ObjectPermissions> bundledOPs = [
      SELECT
        Parent.Label,
        SobjectType,
        PermissionsRead,
        PermissionsCreate,
        PermissionsEdit,
        PermissionsDelete,
        PermissionsViewAllRecords,
        PermissionsModifyAllRecords
      FROM ObjectPermissions
      WHERE ParentId IN :bundledPSIds
      ORDER BY SobjectType
    ];

    Map<String, Set<String>> objToGrantingPS = new Map<String, Set<String>>();
    Map<String, Map<String, Boolean>> objToBasePermissions = new Map<String, Map<String, Boolean>>();

    for (ObjectPermissions op : bundledOPs) {
      if (!objToGrantingPS.containsKey(op.SobjectType)) {
        objToGrantingPS.put(op.SobjectType, new Set<String>());
        objToBasePermissions.put(
          op.SobjectType,
          new Map<String, Boolean>{
            'Read' => false,
            'Create' => false,
            'Edit' => false,
            'Delete' => false,
            'ViewAll' => false,
            'ModifyAll' => false
          }
        );
      }
      objToGrantingPS.get(op.SobjectType).add(op.Parent.Label);

      Map<String, Boolean> base = objToBasePermissions.get(op.SobjectType);
      if (op.PermissionsRead)
        base.put('Read', true);
      if (op.PermissionsCreate)
        base.put('Create', true);
      if (op.PermissionsEdit)
        base.put('Edit', true);
      if (op.PermissionsDelete)
        base.put('Delete', true);
      if (op.PermissionsViewAllRecords)
        base.put('ViewAll', true);
      if (op.PermissionsModifyAllRecords)
        base.put('ModifyAll', true);
    }

    // 2. Effective Group Permissions
    Map<String, Map<String, Boolean>> effectiveMap = new Map<String, Map<String, Boolean>>();
    if (groupPSId != null) {
      List<ObjectPermissions> effOPs = [
        SELECT
          SobjectType,
          PermissionsRead,
          PermissionsCreate,
          PermissionsEdit,
          PermissionsDelete,
          PermissionsViewAllRecords,
          PermissionsModifyAllRecords
        FROM ObjectPermissions
        WHERE ParentId = :groupPSId
      ];
      for (ObjectPermissions op : effOPs) {
        effectiveMap.put(
          op.SobjectType,
          new Map<String, Boolean>{
            'Read' => op.PermissionsRead,
            'Create' => op.PermissionsCreate,
            'Edit' => op.PermissionsEdit,
            'Delete' => op.PermissionsDelete,
            'ViewAll' => op.PermissionsViewAllRecords,
            'ModifyAll' => op.PermissionsModifyAllRecords
          }
        );
      }
    }

    // 3. Build Impact Rows
    List<String> sortedObjs = new List<String>(objToBasePermissions.keySet());
    sortedObjs.sort();

    for (String objName : sortedObjs) {
      Map<String, Boolean> base = objToBasePermissions.get(objName);
      Map<String, Boolean> eff = effectiveMap.containsKey(objName)
        ? effectiveMap.get(objName)
        : new Map<String, Boolean>();

      List<String> mutedOps = new List<String>();
      List<String> activeOps = new List<String>();

      for (String opName : base.keySet()) {
        if (base.get(opName) == true) {
          Boolean isEff = eff.containsKey(opName) && eff.get(opName) == true;
          if (isEff) {
            activeOps.add(opName);
          } else {
            mutedOps.add(opName);
          }
        }
      }

      PSGMutingImpactDTO row = new PSGMutingImpactDTO();
      row.objectName = objName;
      row.bundledSources = String.join(
        new List<String>(objToGrantingPS.get(objName)),
        ', '
      );
      row.bundledAccess = formatObjSummary(base);
      row.effectiveAccess = eff.isEmpty() ? 'No Access' : formatObjSummary(eff);
      row.isMuted = !mutedOps.isEmpty();
      row.mutedPermissions = mutedOps.isEmpty()
        ? 'None'
        : String.join(mutedOps, ', ');
      row.statusBadge = row.isMuted ? 'MUTED' : 'ACTIVE';

      impactRows.add(row);
    }

    return impactRows;
  }

  private static Map<String, Boolean> buildObjFlags(ObjectPermissions op) {
    if (op == null) {
      return new Map<String, Boolean>{
        'Read' => false,
        'Create' => false,
        'Edit' => false,
        'Delete' => false,
        'ViewAll' => false,
        'ModifyAll' => false
      };
    }
    return new Map<String, Boolean>{
      'Read' => op.PermissionsRead,
      'Create' => op.PermissionsCreate,
      'Edit' => op.PermissionsEdit,
      'Delete' => op.PermissionsDelete,
      'ViewAll' => op.PermissionsViewAllRecords,
      'ModifyAll' => op.PermissionsModifyAllRecords
    };
  }

  private static String formatObjSummary(Map<String, Boolean> flags) {
    List<String> perms = new List<String>();
    if (flags.get('Read') == true)
      perms.add('Read');
    if (flags.get('Create') == true)
      perms.add('Create');
    if (flags.get('Edit') == true)
      perms.add('Edit');
    if (flags.get('Delete') == true)
      perms.add('Delete');
    if (flags.get('ViewAll') == true)
      perms.add('View All');
    if (flags.get('ModifyAll') == true)
      perms.add('Modify All');
    return perms.isEmpty() ? 'No Access' : String.join(perms, ', ');
  }

  private static String formatFieldSummary(Map<String, Boolean> flags) {
    List<String> perms = new List<String>();
    if (flags.get('Read') == true)
      perms.add('Read');
    if (flags.get('Edit') == true)
      perms.add('Edit');
    return perms.isEmpty() ? 'No Access' : String.join(perms, ', ');
  }

  private static Boolean flagsEqual(
    Map<String, Boolean> f1,
    Map<String, Boolean> f2
  ) {
    for (String key : f1.keySet()) {
      if (f1.get(key) != f2.get(key))
        return false;
    }
    return true;
  }

  // --- DTO Classes ---

  public class EntityOptionDTO implements Comparable {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String entityType;
    @AuraEnabled
    public String description;

    public Integer compareTo(Object compareTo) {
      EntityOptionDTO other = (EntityOptionDTO) compareTo;
      if (this.label == null)
        return 1;
      if (other.label == null)
        return -1;
      return this.label.toLowerCase().compareTo(other.label.toLowerCase());
    }
  }

  public class ComparisonResultDTO {
    @AuraEnabled
    public String category;
    @AuraEnabled
    public EntityOptionDTO leftEntity;
    @AuraEnabled
    public EntityOptionDTO rightEntity;
    @AuraEnabled
    public Integer totalItems;
    @AuraEnabled
    public Integer identicalCount;
    @AuraEnabled
    public Integer differentCount;
    @AuraEnabled
    public Integer leftOnlyCount;
    @AuraEnabled
    public Integer rightOnlyCount;
    @AuraEnabled
    public List<ComparisonRowDTO> rows;
  }

  public class ComparisonRowDTO {
    @AuraEnabled
    public String itemKey;
    @AuraEnabled
    public String itemLabel;
    @AuraEnabled
    public String category;
    @AuraEnabled
    public String diffStatus; // IDENTICAL | DIFFERENT | LEFT_ONLY | RIGHT_ONLY
    @AuraEnabled
    public String leftAccess;
    @AuraEnabled
    public String rightAccess;
    @AuraEnabled
    public Map<String, Boolean> leftFlags;
    @AuraEnabled
    public Map<String, Boolean> rightFlags;
  }

  public class PSGOptionDTO {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String developerName;
    @AuraEnabled
    public String masterLabel;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Boolean hasActivationRequired;
    @AuraEnabled
    public Integer bundledCount;
    @AuraEnabled
    public Boolean hasMuting;
  }

  public class PSGDetailDTO {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String developerName;
    @AuraEnabled
    public String masterLabel;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Boolean hasActivationRequired;
    @AuraEnabled
    public Boolean hasMuting;
    @AuraEnabled
    public Id mutingSetId;
    @AuraEnabled
    public String mutingSetName;
    @AuraEnabled
    public String mutingSetLabel;
    @AuraEnabled
    public List<PSGBundledSetDTO> bundledPermissionSets;
    @AuraEnabled
    public List<PSGMutingImpactDTO> mutingImpactRows;
  }

  public class PSGBundledSetDTO {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String type;
  }

  public class PSGMutingImpactDTO {
    @AuraEnabled
    public String objectName;
    @AuraEnabled
    public String bundledSources;
    @AuraEnabled
    public String bundledAccess;
    @AuraEnabled
    public String effectiveAccess;
    @AuraEnabled
    public Boolean isMuted;
    @AuraEnabled
    public String mutedPermissions;
    @AuraEnabled
    public String statusBadge;
  }
}
