@IsTest
private class WhoHasAccessControllerTest {
  @IsTest
  static void testGetSearchableSObjects() {
    Test.startTest();
    List<WhoHasAccessController.OptionDTO> options = WhoHasAccessController.getSearchableSObjects();
    Test.stopTest();

    System.assertNotEquals(null, options, 'SObject options should not be null');
    System.assert(options.size() > 0, 'Should find searchable sObjects');
  }

  @IsTest
  static void testGetObjectFields() {
    Test.startTest();
    List<WhoHasAccessController.OptionDTO> emptyFields = WhoHasAccessController.getObjectFields('');
    System.assertEquals(0, emptyFields.size(), 'Should return empty for blank object');

    List<WhoHasAccessController.OptionDTO> invalidFields = WhoHasAccessController.getObjectFields('NonExistentObjectXYZ__c');
    System.assertEquals(0, invalidFields.size(), 'Should return empty for invalid object');

    List<WhoHasAccessController.OptionDTO> accFields = WhoHasAccessController.getObjectFields('Account');
    Test.stopTest();

    System.assertNotEquals(null, accFields, 'Account fields should not be null');
    System.assert(accFields.size() > 0, 'Should find Account fields');
  }

  @IsTest
  static void testSearchApexClassesAndFlows() {
    Test.startTest();
    List<WhoHasAccessController.OptionDTO> classes = WhoHasAccessController.searchApexClasses('WhoHasAccess');
    System.assertNotEquals(null, classes, 'Apex classes should not be null');

    List<WhoHasAccessController.OptionDTO> flows = WhoHasAccessController.searchFlows('');
    System.assertNotEquals(null, flows, 'Flows should not be null');
    Test.stopTest();
  }

  @IsTest
  static void testGetSystemPermissionsList() {
    Test.startTest();
    List<WhoHasAccessController.OptionDTO> perms = WhoHasAccessController.getSystemPermissionsList();
    Test.stopTest();

    System.assertNotEquals(null, perms, 'System permissions should not be null');
    System.assert(perms.size() > 0, 'Should return system permissions');
  }

  @IsTest
  static void testGetUsersWithAccessObject() {
    Test.startTest();
    // Test validation exception
    try {
      WhoHasAccessController.getUsersWithAccess('', '', '', true);
      System.assert(false, 'Should have thrown an exception');
    } catch (Exception e) {
      System.assert(true);
    }

    // Test OBJECT read access
    WhoHasAccessController.WhoHasAccessResponseDTO readResponse = WhoHasAccessController.getUsersWithAccess(
      'OBJECT',
      'Account',
      'Read',
      true
    );
    System.assertNotEquals(null, readResponse, 'Response should not be null');
    System.assertEquals('OBJECT', readResponse.category);
    System.assert(readResponse.totalUsersCount >= 0, 'Total users should be >= 0');

    // Test OBJECT delete access
    WhoHasAccessController.WhoHasAccessResponseDTO deleteResponse = WhoHasAccessController.getUsersWithAccess(
      'OBJECT',
      'Account',
      'Delete',
      false
    );
    System.assertNotEquals(null, deleteResponse, 'Response should not be null');
    Test.stopTest();
  }

  @IsTest
  static void testGetUsersWithAccessField() {
    Test.startTest();
    WhoHasAccessController.WhoHasAccessResponseDTO fieldResponse = WhoHasAccessController.getUsersWithAccess(
      'FIELD',
      'Account.AccountNumber',
      'Read',
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, fieldResponse, 'Field response should not be null');
    System.assertEquals('FIELD', fieldResponse.category);
  }

  @IsTest
  static void testGetUsersWithAccessSystemPermission() {
    Test.startTest();
    WhoHasAccessController.WhoHasAccessResponseDTO sysResponse = WhoHasAccessController.getUsersWithAccess(
      'SYSTEM',
      'PermissionsModifyAllData',
      '',
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, sysResponse, 'System response should not be null');
    System.assertEquals('SYSTEM', sysResponse.category);
  }

  @IsTest
  static void testGetUsersWithAccessApex() {
    Test.startTest();
    WhoHasAccessController.WhoHasAccessResponseDTO apexResponse = WhoHasAccessController.getUsersWithAccess(
      'APEX',
      'WhoHasAccessController',
      '',
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, apexResponse, 'Apex response should not be null');
  }

  @IsTest
  static void testGetUsersWithAccessFlow() {
    Test.startTest();
    WhoHasAccessController.WhoHasAccessResponseDTO flowResponse = WhoHasAccessController.getUsersWithAccess(
      'FLOW',
      'SampleFlow',
      '',
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, flowResponse, 'Flow response should not be null');
  }

  @IsTest
  static void testComparables() {
    WhoHasAccessController.OptionDTO opt1 = new WhoHasAccessController.OptionDTO('b', 'Beta');
    WhoHasAccessController.OptionDTO opt2 = new WhoHasAccessController.OptionDTO('a', 'Alpha');
    WhoHasAccessController.OptionDTO opt3 = new WhoHasAccessController.OptionDTO('c', null);

    Test.startTest();
    System.assert(opt1.compareTo(opt2) > 0);
    System.assert(opt2.compareTo(opt1) < 0);
    System.assert(opt3.compareTo(opt1) > 0);
    System.assert(opt1.compareTo(opt3) < 0);

    WhoHasAccessController.UserAccessResultDTO u1 = new WhoHasAccessController.UserAccessResultDTO();
    u1.name = 'Bob';
    WhoHasAccessController.UserAccessResultDTO u2 = new WhoHasAccessController.UserAccessResultDTO();
    u2.name = 'Alice';
    WhoHasAccessController.UserAccessResultDTO u3 = new WhoHasAccessController.UserAccessResultDTO();
    u3.name = null;

    System.assert(u1.compareTo(u2) > 0);
    System.assert(u2.compareTo(u1) < 0);
    System.assert(u3.compareTo(u1) > 0);
    System.assert(u1.compareTo(u3) < 0);
    Test.stopTest();
  }
}