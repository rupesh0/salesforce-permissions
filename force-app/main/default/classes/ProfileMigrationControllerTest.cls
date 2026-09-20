@IsTest
private class ProfileMigrationControllerTest {
  @TestSetup
  static void setupTestData() {
    Profile stdProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];

    String uniqueSuffix = String.valueOf(DateTime.now().getTime());
    User testUser = new User(
      FirstName = 'Migrate',
      LastName = 'TestUser' + uniqueSuffix.right(4),
      Email = 'migrateuser' + uniqueSuffix + '@example.com',
      Username = 'migrateuser' + uniqueSuffix + '@example.com',
      Alias = 'mgusr',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = stdProfile.Id,
      LanguageLocaleKey = 'en_US'
    );
    insert testUser;
  }

  @IsTest
  static void testGetMigratableProfiles() {
    Test.startTest();
    List<ProfileMigrationController.ProfileSummaryDTO> profiles = ProfileMigrationController.getMigratableProfiles();
    Test.stopTest();

    System.assertNotEquals(null, profiles, 'Profiles list should not be null');
    System.assert(profiles.size() > 0, 'Should find at least one profile');

    Boolean foundStd = false;
    for (ProfileMigrationController.ProfileSummaryDTO dto : profiles) {
      if (dto.name == 'Standard User') {
        foundStd = true;
        System.assertNotEquals(null, dto.id, 'Id must be populated');
        System.assertEquals(false, dto.isCustom, 'Standard User is standard');
        System.assert(dto.totalUserCount > 0, 'Should have users');
      }
    }
    System.assert(foundStd, 'Standard User profile should be in list');
  }

  @IsTest
  static void testAnalyzeProfilePermissions() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

    Test.startTest();
    ProfileMigrationController.ProfileAnalysisDTO analysis = ProfileMigrationController.analyzeProfilePermissions(
      p.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, analysis, 'Analysis should not be null');
    System.assertEquals(p.Id, analysis.profileId, 'Profile ID must match');
    System.assertNotEquals(
      null,
      analysis.permissionSetId,
      'Underlying PermissionSet must be resolved'
    );
    System.assert(analysis.totalObjects >= 0, 'Total objects should be >= 0');
    System.assert(analysis.totalFields >= 0, 'Total fields should be >= 0');
    System.assert(
      analysis.totalSystemPerms >= 0,
      'Total system perms should be >= 0'
    );
    System.assert(analysis.assignedActiveUsers > 0, 'Should have active users');
  }

  @IsTest
  static void testAnalyzeProfilePermissions_NullId() {
    Boolean caught = false;
    try {
      ProfileMigrationController.analyzeProfilePermissions(null);
    } catch (AuraHandledException e) {
      caught = true;
    }
    System.assert(caught, 'Should throw exception for null profile ID');
  }

  @IsTest
  static void testGeneratePermissionSet_StandardFlow() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    String uniqueName = 'Test_Gen_PS_' + DateTime.now().getTime();

    ProfileMigrationController.MigrationRequestDTO req = new ProfileMigrationController.MigrationRequestDTO();
    req.sourceProfileId = p.Id;
    req.targetType = 'PERMISSION_SET';
    req.targetName = uniqueName;
    req.targetLabel = 'Test Gen PS';
    req.description = 'Generated in unit test';
    req.includeObjects = true;
    req.includeFields = true;
    req.includeSystemPerms = true;
    req.includeApexClasses = true;

    Test.startTest();
    ProfileMigrationController.MigrationResultDTO result = ProfileMigrationController.generatePermissionSet(
      req
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(true, result.success, 'Migration should succeed');
    System.assertNotEquals(
      null,
      result.permissionSetId,
      'PermissionSet ID must be returned'
    );
    System.assertEquals(uniqueName, result.permissionSetName, 'Name must match');
  }

  @IsTest
  static void testGeneratePermissionSet_WithPSGAndObjectFilter() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    String uniqueName = 'Test_PSG_Gen_' + DateTime.now().getTime();

    ProfileMigrationController.MigrationRequestDTO req = new ProfileMigrationController.MigrationRequestDTO();
    req.sourceProfileId = p.Id;
    req.targetType = 'PERMISSION_SET_GROUP';
    req.targetName = uniqueName;
    req.targetLabel = 'Test PSG Gen';
    req.description = 'Generated PSG test';
    req.includeObjects = true;
    req.includeFields = true;
    req.includeSystemPerms = false;
    req.includeApexClasses = false;
    req.selectedObjects = new List<String>{ 'Account', 'Contact' };

    Test.startTest();
    ProfileMigrationController.MigrationResultDTO result = ProfileMigrationController.generatePermissionSet(
      req
    );
    Test.stopTest();

    System.assertEquals(true, result.success, 'PSG generation should succeed');
    System.assertNotEquals(
      null,
      result.permissionSetGroupId,
      'PSG ID must be generated'
    );
  }

  @IsTest
  static void testGeneratePermissionSet_ValidationErrors() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

    // 1. Null request
    try {
      ProfileMigrationController.generatePermissionSet(null);
      System.assert(false, 'Should fail for null request');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 2. Missing source profile
    ProfileMigrationController.MigrationRequestDTO req = new ProfileMigrationController.MigrationRequestDTO();
    req.targetName = 'Valid_Name';
    req.targetLabel = 'Valid Label';
    try {
      ProfileMigrationController.generatePermissionSet(req);
      System.assert(false, 'Should fail for missing profile');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 3. Blank target name
    req.sourceProfileId = p.Id;
    req.targetName = '';
    try {
      ProfileMigrationController.generatePermissionSet(req);
      System.assert(false, 'Should fail for blank name');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 4. Blank target label
    req.targetName = 'Valid_Name';
    req.targetLabel = '';
    try {
      ProfileMigrationController.generatePermissionSet(req);
      System.assert(false, 'Should fail for blank label');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 5. Invalid API name (spaces/symbols)
    req.targetLabel = 'Valid Label';
    req.targetName = 'Invalid Name With Spaces!';
    try {
      ProfileMigrationController.generatePermissionSet(req);
      System.assert(false, 'Should fail for invalid characters');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 6. Duplicate API name
    PermissionSet existingPS = new PermissionSet(
      Name = 'Dup_Test_PS_' + DateTime.now().getTime(),
      Label = 'Duplicate Test PS'
    );
    insert existingPS;

    req.targetName = existingPS.Name;
    try {
      ProfileMigrationController.generatePermissionSet(req);
      System.assert(false, 'Should fail for duplicate name');
    } catch (AuraHandledException e) {
      System.assert(true);
    }
  }

  @IsTest
  static void testUserMigrationPreviewAndExecuteAndRollback() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User u = [
      SELECT Id
      FROM User
      WHERE ProfileId = :p.Id AND IsActive = TRUE
      LIMIT 1
    ];

    // Create a target Permission Set
    PermissionSet ps = new PermissionSet(
      Name = 'Test_User_Mig_PS_' + DateTime.now().getTime(),
      Label = 'Test User Mig PS'
    );
    insert ps;

    Test.startTest();
    // 1. Preview with Permission Set
    ProfileMigrationController.UserMigrationPreviewDTO preview = ProfileMigrationController.previewUserMigration(
      p.Id,
      ps.Id,
      null
    );
    System.assertNotEquals(null, preview, 'Preview should not be null');
    System.assert(preview.toAssignCount > 0, 'Should have users ready to assign');

    // 2. Execute with Permission Set
    ProfileMigrationController.UserMigrationExecutionResultDTO execResult = ProfileMigrationController.executeUserMigration(
      p.Id,
      ps.Id,
      null,
      new List<Id>{ u.Id }
    );
    System.assertEquals(true, execResult.success, 'Execution should succeed');
    System.assertEquals(1, execResult.successCount, 'Should assign 1 user');
    System.assertEquals(
      1,
      execResult.createdAssignmentIds.size(),
      'Should return 1 assignment ID'
    );

    // 3. Rollback
    ProfileMigrationController.UserMigrationRollbackResultDTO rollbackResult = ProfileMigrationController.rollbackUserAssignments(
      execResult.createdAssignmentIds
    );
    System.assertEquals(true, rollbackResult.success, 'Rollback should succeed');
    System.assertEquals(
      1,
      rollbackResult.rolledBackCount,
      'Should roll back 1 assignment'
    );
    Test.stopTest();
  }

  @IsTest
  static void testUserMigrationWithPSG() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User u = [
      SELECT Id
      FROM User
      WHERE ProfileId = :p.Id AND IsActive = TRUE
      LIMIT 1
    ];

    // Create PSG
    PermissionSetGroup psg = new PermissionSetGroup(
      DeveloperName = 'Test_User_Mig_PSG_' + DateTime.now().getTime(),
      MasterLabel = 'Test User Mig PSG'
    );
    insert psg;

    Test.startTest();
    ProfileMigrationController.UserMigrationPreviewDTO preview = ProfileMigrationController.previewUserMigration(
      p.Id,
      null,
      psg.Id
    );
    System.assertNotEquals(null, preview, 'Preview with PSG should not be null');

    ProfileMigrationController.UserMigrationExecutionResultDTO execResult = ProfileMigrationController.executeUserMigration(
      p.Id,
      null,
      psg.Id,
      new List<Id>{ u.Id }
    );
    System.assertEquals(true, execResult.success, 'Execution with PSG should succeed');
    Test.stopTest();
  }

  @IsTest
  static void testUserMigration_ValidationErrors() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

    // 1. preview null profile
    try {
      ProfileMigrationController.previewUserMigration(null, null, null);
      System.assert(false);
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 2. execute empty userIds
    try {
      ProfileMigrationController.executeUserMigration(p.Id, null, null, new List<Id>());
      System.assert(false);
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 3. execute null targets
    try {
      ProfileMigrationController.executeUserMigration(p.Id, null, null, new List<Id>{ UserInfo.getUserId() });
      System.assert(false);
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // 4. rollback empty IDs
    try {
      ProfileMigrationController.rollbackUserAssignments(new List<Id>());
      System.assert(false);
    } catch (AuraHandledException e) {
      System.assert(true);
    }
  }

  @IsTest
  static void testDTOComparators() {
    // ProfileSummaryDTO
    ProfileMigrationController.ProfileSummaryDTO p1 = new ProfileMigrationController.ProfileSummaryDTO();
    p1.name = 'Alpha';
    ProfileMigrationController.ProfileSummaryDTO p2 = new ProfileMigrationController.ProfileSummaryDTO();
    p2.name = 'Beta';
    ProfileMigrationController.ProfileSummaryDTO pNull1 = new ProfileMigrationController.ProfileSummaryDTO();
    ProfileMigrationController.ProfileSummaryDTO pNull2 = new ProfileMigrationController.ProfileSummaryDTO();
    System.assert(p1.compareTo(p2) < 0, 'Alpha should be before Beta');
    System.assertEquals(-1, pNull1.compareTo(p2));
    System.assertEquals(1, p1.compareTo(pNull2));

    // ObjectPermDTO
    ProfileMigrationController.ObjectPermDTO o1 = new ProfileMigrationController.ObjectPermDTO();
    o1.objectName = 'Account';
    ProfileMigrationController.ObjectPermDTO o2 = new ProfileMigrationController.ObjectPermDTO();
    o2.objectName = 'Contact';
    ProfileMigrationController.ObjectPermDTO oNull = new ProfileMigrationController.ObjectPermDTO();
    System.assert(o1.compareTo(o2) < 0);
    System.assertEquals(-1, oNull.compareTo(o2));
    System.assertEquals(1, o1.compareTo(oNull));

    // FieldPermDTO
    ProfileMigrationController.FieldPermDTO f1 = new ProfileMigrationController.FieldPermDTO();
    f1.objectName = 'Account';
    f1.fieldName = 'Name';
    ProfileMigrationController.FieldPermDTO f2 = new ProfileMigrationController.FieldPermDTO();
    f2.objectName = 'Account';
    f2.fieldName = 'Type';
    System.assert(f1.compareTo(f2) < 0);

    // SystemPermDTO
    ProfileMigrationController.SystemPermDTO s1 = new ProfileMigrationController.SystemPermDTO();
    s1.label = 'API Enabled';
    ProfileMigrationController.SystemPermDTO s2 = new ProfileMigrationController.SystemPermDTO();
    s2.label = 'View Setup';
    System.assert(s1.compareTo(s2) < 0);

    // ApexClassPermDTO
    ProfileMigrationController.ApexClassPermDTO a1 = new ProfileMigrationController.ApexClassPermDTO();
    a1.className = 'ClassA';
    ProfileMigrationController.ApexClassPermDTO a2 = new ProfileMigrationController.ApexClassPermDTO();
    a2.className = 'ClassB';
    ProfileMigrationController.ApexClassPermDTO aNull = new ProfileMigrationController.ApexClassPermDTO();
    System.assert(a1.compareTo(a2) < 0);
    System.assertEquals(-1, aNull.compareTo(a2));
    System.assertEquals(1, a1.compareTo(aNull));

    // UserMigrationItemDTO
    ProfileMigrationController.UserMigrationItemDTO u1 = new ProfileMigrationController.UserMigrationItemDTO();
    u1.name = 'Alice';
    ProfileMigrationController.UserMigrationItemDTO u2 = new ProfileMigrationController.UserMigrationItemDTO();
    u2.name = 'Bob';
    ProfileMigrationController.UserMigrationItemDTO uNull = new ProfileMigrationController.UserMigrationItemDTO();
    System.assert(u1.compareTo(u2) < 0);
    System.assertEquals(-1, uNull.compareTo(u2));
    System.assertEquals(1, u1.compareTo(uNull));
  }
}
