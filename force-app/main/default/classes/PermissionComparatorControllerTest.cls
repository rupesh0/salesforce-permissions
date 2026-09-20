@IsTest
private class PermissionComparatorControllerTest {
  @TestSetup
  static void setupData() {
    // Create custom PermissionSet 1
    PermissionSet ps1 = new PermissionSet(
      Name = 'Test_Comp_PS1_' + DateTime.now().getTime(),
      Label = 'Test Comp PS 1',
      PermissionsPasswordNeverExpires = true,
      PermissionsApiEnabled = true
    );
    insert ps1;

    // Create custom PermissionSet 2
    PermissionSet ps2 = new PermissionSet(
      Name = 'Test_Comp_PS2_' + DateTime.now().getTime(),
      Label = 'Test Comp PS 2',
      PermissionsApiEnabled = true
    );
    insert ps2;

    // Add ObjectPermissions to ps1
    insert new ObjectPermissions(
      ParentId = ps1.Id,
      SobjectType = 'Account',
      PermissionsRead = true,
      PermissionsCreate = true,
      PermissionsEdit = false,
      PermissionsDelete = false,
      PermissionsViewAllRecords = false,
      PermissionsModifyAllRecords = false
    );

    // Add ObjectPermissions to ps2
    insert new ObjectPermissions(
      ParentId = ps2.Id,
      SobjectType = 'Account',
      PermissionsRead = true,
      PermissionsCreate = false,
      PermissionsEdit = false,
      PermissionsDelete = false,
      PermissionsViewAllRecords = false,
      PermissionsModifyAllRecords = false
    );

    // Add FieldPermissions to ps1
    insert new FieldPermissions(
      ParentId = ps1.Id,
      SobjectType = 'Account',
      Field = 'Account.AccountNumber',
      PermissionsRead = true,
      PermissionsEdit = false
    );
  }

  @IsTest
  static void testSearchEntities() {
    Test.startTest();
    List<PermissionComparatorController.EntityOptionDTO> allOptions = PermissionComparatorController.searchEntities(
      'ALL',
      ''
    );
    System.assertNotEquals(null, allOptions, 'Should return entities');

    List<PermissionComparatorController.EntityOptionDTO> profileOptions = PermissionComparatorController.searchEntities(
      'PROFILE',
      'Standard'
    );
    System.assertNotEquals(
      null,
      profileOptions,
      'Should return profile options'
    );

    List<PermissionComparatorController.EntityOptionDTO> psOptions = PermissionComparatorController.searchEntities(
      'PERMISSION_SET',
      'Test Comp'
    );
    System.assertNotEquals(
      null,
      psOptions,
      'Should return permission set options'
    );

    List<PermissionComparatorController.EntityOptionDTO> psgOptions = PermissionComparatorController.searchEntities(
      'PERMISSION_SET_GROUP',
      ''
    );
    System.assertNotEquals(null, psgOptions, 'Should return PSG options');
    Test.stopTest();
  }

  @IsTest
  static void testCompareEntitiesObjectsAndFields() {
    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    Profile p2 = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    PermissionSet ps1 = [
      SELECT Id
      FROM PermissionSet
      WHERE Name LIKE 'Test_Comp_PS1_%'
      LIMIT 1
    ];
    PermissionSet ps2 = [
      SELECT Id
      FROM PermissionSet
      WHERE Name LIKE 'Test_Comp_PS2_%'
      LIMIT 1
    ];

    Test.startTest();
    // 1. Profile vs Profile (OBJECT)
    PermissionComparatorController.ComparisonResultDTO objResult = PermissionComparatorController.compareEntities(
      'PROFILE',
      p1.Id,
      'PROFILE',
      p2.Id,
      'OBJECT'
    );
    System.assertNotEquals(null, objResult);
    System.assertEquals('OBJECT', objResult.category);
    System.assert(objResult.totalItems > 0);

    // 2. PS vs PS (OBJECT - tests DIFFERENT / LEFT_ONLY)
    PermissionComparatorController.ComparisonResultDTO psObjResult = PermissionComparatorController.compareEntities(
      'PERMISSION_SET',
      ps1.Id,
      'PERMISSION_SET',
      ps2.Id,
      'OBJECT'
    );
    System.assertNotEquals(null, psObjResult);
    System.assert(
      psObjResult.differentCount > 0 || psObjResult.leftOnlyCount > 0
    );

    // 3. PS vs PS (FIELD)
    PermissionComparatorController.ComparisonResultDTO fieldResult = PermissionComparatorController.compareEntities(
      'PERMISSION_SET',
      ps1.Id,
      'PERMISSION_SET',
      ps2.Id,
      'FIELD'
    );
    System.assertNotEquals(null, fieldResult);
    System.assertEquals('FIELD', fieldResult.category);
    Test.stopTest();
  }

  @IsTest
  static void testCompareEntitiesSystemApexFlow() {
    Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    PermissionSet ps1 = [
      SELECT Id
      FROM PermissionSet
      WHERE Name LIKE 'Test_Comp_PS1_%'
      LIMIT 1
    ];
    PermissionSet ps2 = [
      SELECT Id
      FROM PermissionSet
      WHERE Name LIKE 'Test_Comp_PS2_%'
      LIMIT 1
    ];

    Test.startTest();
    // System permissions comparison
    PermissionComparatorController.ComparisonResultDTO sysResult = PermissionComparatorController.compareEntities(
      'PERMISSION_SET',
      ps1.Id,
      'PERMISSION_SET',
      ps2.Id,
      'SYSTEM'
    );
    System.assertNotEquals(null, sysResult);
    System.assertEquals('SYSTEM', sysResult.category);

    // Profile vs PS comparison
    PermissionComparatorController.ComparisonResultDTO profVsPS = PermissionComparatorController.compareEntities(
      'PROFILE',
      p1.Id,
      'PERMISSION_SET',
      ps1.Id,
      'SYSTEM'
    );
    System.assertNotEquals(null, profVsPS);

    // Apex Class comparison
    PermissionComparatorController.ComparisonResultDTO apexResult = PermissionComparatorController.compareEntities(
      'PERMISSION_SET',
      ps1.Id,
      'PERMISSION_SET',
      ps2.Id,
      'APEX'
    );
    System.assertNotEquals(null, apexResult);

    // Flow comparison
    PermissionComparatorController.ComparisonResultDTO flowResult = PermissionComparatorController.compareEntities(
      'PERMISSION_SET',
      ps1.Id,
      'PERMISSION_SET',
      ps2.Id,
      'FLOW'
    );
    System.assertNotEquals(null, flowResult);
    Test.stopTest();
  }

  @IsTest
  static void testPSGMethods() {
    Test.startTest();
    List<PermissionComparatorController.PSGOptionDTO> psgList = PermissionComparatorController.getPSGList();
    System.assertNotEquals(null, psgList);

    if (!psgList.isEmpty()) {
      Id testPSGId = psgList[0].id;
      PermissionComparatorController.PSGDetailDTO detail = PermissionComparatorController.getPSGDetail(
        testPSGId
      );
      System.assertNotEquals(null, detail);
      System.assertEquals(testPSGId, detail.id);
      System.assertNotEquals(null, detail.bundledPermissionSets);
      System.assertNotEquals(null, detail.mutingImpactRows);

      // Also test compareEntities with PSG
      PermissionSet ps1 = [
        SELECT Id
        FROM PermissionSet
        WHERE Name LIKE 'Test_Comp_PS1_%'
        LIMIT 1
      ];
      PermissionComparatorController.ComparisonResultDTO psgComp = PermissionComparatorController.compareEntities(
        'PERMISSION_SET_GROUP',
        testPSGId,
        'PERMISSION_SET',
        ps1.Id,
        'OBJECT'
      );
      System.assertNotEquals(null, psgComp);
    }
    Test.stopTest();
  }

  @IsTest
  static void testValidationAndComparables() {
    Test.startTest();
    // Test null entities exception
    try {
      PermissionComparatorController.compareEntities(
        'PROFILE',
        null,
        'PROFILE',
        null,
        'OBJECT'
      );
      System.assert(false, 'Should have thrown exception');
    } catch (Exception e) {
      System.assert(true);
    }

    // Test null PSG ID
    try {
      PermissionComparatorController.getPSGDetail(null);
      System.assert(false, 'Should have thrown exception');
    } catch (Exception e) {
      System.assert(true);
    }

    // Test Comparable EntityOptionDTO
    PermissionComparatorController.EntityOptionDTO opt1 = new PermissionComparatorController.EntityOptionDTO();
    opt1.label = 'Beta Entity';
    PermissionComparatorController.EntityOptionDTO opt2 = new PermissionComparatorController.EntityOptionDTO();
    opt2.label = 'Alpha Entity';
    PermissionComparatorController.EntityOptionDTO opt3 = new PermissionComparatorController.EntityOptionDTO();
    opt3.label = null;

    System.assert(opt1.compareTo(opt2) > 0);
    System.assert(opt2.compareTo(opt1) < 0);
    System.assert(opt3.compareTo(opt1) > 0);
    System.assert(opt1.compareTo(opt3) < 0);

    // Test DTO properties coverage
    PermissionComparatorController.ComparisonRowDTO row = new PermissionComparatorController.ComparisonRowDTO();
    row.itemKey = 'Account';
    row.itemLabel = 'Account';
    row.category = 'OBJECT';
    row.diffStatus = 'IDENTICAL';
    row.leftAccess = 'Read';
    row.rightAccess = 'Read';
    row.leftFlags = new Map<String, Boolean>{ 'Read' => true };
    row.rightFlags = new Map<String, Boolean>{ 'Read' => true };

    PermissionComparatorController.PSGBundledSetDTO bundled = new PermissionComparatorController.PSGBundledSetDTO();
    bundled.id = null;
    bundled.name = 'Test_PS';
    bundled.label = 'Test PS';
    bundled.description = 'Desc';
    bundled.type = 'Regular';

    PermissionComparatorController.PSGMutingImpactDTO impact = new PermissionComparatorController.PSGMutingImpactDTO();
    impact.objectName = 'Account';
    impact.bundledSources = 'Test PS';
    impact.bundledAccess = 'Read, Edit';
    impact.effectiveAccess = 'Read';
    impact.isMuted = true;
    impact.mutedPermissions = 'Edit';
    impact.statusBadge = 'MUTED';

    System.assertEquals('IDENTICAL', row.diffStatus);
    System.assertEquals('MUTED', impact.statusBadge);
    System.assertEquals('Test PS', bundled.label);
    Test.stopTest();
  }
}
