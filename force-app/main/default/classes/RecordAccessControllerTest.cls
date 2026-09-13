@IsTest
private class RecordAccessControllerTest {
  @IsTest
  static void testGetSearchableSObjects() {
    Test.startTest();
    List<RecordAccessController.SObjectOption> options = RecordAccessController.getSearchableSObjects();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
    System.assert(options.size() > 0, 'Should find at least one searchable sObject');
  }

  @IsTest
  static void testSearchRecords() {
    Account acc = new Account(Name = 'Test Record Access Account');
    insert acc;

    Test.startTest();
    // Test with blank object name
    List<RecordAccessController.RecordOption> emptyObjResults = RecordAccessController.searchRecords('', 'Test');
    System.assertEquals(0, emptyObjResults.size(), 'Should return empty for blank object name');

    // Test with invalid object name
    List<RecordAccessController.RecordOption> invalidObjResults = RecordAccessController.searchRecords('Invalid_NonExistent_Object__xyz', 'Test');
    System.assertEquals(0, invalidObjResults.size(), 'Should return empty for invalid object name');

    // Test search by name
    List<RecordAccessController.RecordOption> nameResults = RecordAccessController.searchRecords('Account', 'Test Record Access');
    System.assert(nameResults.size() > 0, 'Should find account by name');

    // Test search by ID
    List<RecordAccessController.RecordOption> idResults = RecordAccessController.searchRecords('Account', acc.Id);
    System.assert(idResults.size() > 0, 'Should find account by ID');
    System.assertEquals(acc.Id, idResults[0].id, 'Record ID should match');
    Test.stopTest();
  }

  @IsTest
  static void testSearchUsers() {
    User currentUser = [SELECT Id, Name, Username FROM User WHERE Id = :UserInfo.getUserId()];

    Test.startTest();
    List<RecordAccessController.UserOption> allUsers = RecordAccessController.searchUsers('');
    System.assert(allUsers.size() > 0, 'Should return users on empty query');

    List<RecordAccessController.UserOption> specificUsers = RecordAccessController.searchUsers(currentUser.Name);
    System.assert(specificUsers.size() > 0, 'Should find current user by name');
    Test.stopTest();
  }

  @IsTest
  static void testCheckRecordAccess() {
    Account acc = new Account(Name = 'Test Access Account');
    insert acc;
    Id currentUserId = UserInfo.getUserId();

    Test.startTest();
    // Test with null inputs
    RecordAccessController.RecordAccessMatrixDTO emptyResult = RecordAccessController.checkRecordAccess(null, null);
    System.assertEquals(null, emptyResult.rows, 'Empty input should return empty matrix');

    // Test with valid inputs
    RecordAccessController.RecordAccessMatrixDTO matrix = RecordAccessController.checkRecordAccess(
      new List<Id>{ acc.Id },
      new List<Id>{ currentUserId }
    );
    Test.stopTest();

    System.assertNotEquals(null, matrix, 'Matrix should not be null');
    System.assertNotEquals(null, matrix.users, 'Users should not be null');
    System.assertEquals(1, matrix.users.size(), 'Should have 1 user');
    System.assertNotEquals(null, matrix.rows, 'Rows should not be null');
    System.assertEquals(1, matrix.rows.size(), 'Should have 1 row');
    System.assert(matrix.rows[0].userAccess.containsKey(String.valueOf(currentUserId)), 'User access map should contain user');
  }

  @IsTest
  static void testGetRecordSharingDetails() {
    Account acc = new Account(Name = 'Test Sharing Account');
    insert acc;
    Id currentUserId = UserInfo.getUserId();

    Test.startTest();
    // Test with null inputs
    RecordAccessController.RecordSharingExplanationDTO emptyDTO = RecordAccessController.getRecordSharingDetails(null, null);
    System.assertEquals(null, emptyDTO.userExplanations, 'Null inputs should return empty explanation');

    // Test with valid inputs
    RecordAccessController.RecordSharingExplanationDTO details = RecordAccessController.getRecordSharingDetails(
      acc.Id,
      new List<Id>{ currentUserId }
    );

    System.assertNotEquals(null, details, 'Details should not be null');
    System.assertEquals(acc.Id, details.recordId, 'Record ID should match');
    System.assertNotEquals(null, details.userExplanations, 'User explanations should not be null');
    System.assert(details.userExplanations.size() > 0, 'Should have explanation for current user');

    // Also test with a Case record to exercise Case share fields
    Case c = new Case(Subject = 'Test Case Record Access');
    insert c;
    RecordAccessController.RecordSharingExplanationDTO caseDetails = RecordAccessController.getRecordSharingDetails(
      c.Id,
      new List<Id>{ currentUserId }
    );
    System.assertNotEquals(null, caseDetails, 'Case details should not be null');
    System.assertEquals(c.Id, caseDetails.recordId, 'Case Record ID should match');
    Test.stopTest();
  }

  @IsTest
  static void testSObjectOptionComparable() {
    RecordAccessController.SObjectOption opt1 = new RecordAccessController.SObjectOption();
    opt1.label = 'Beta';
    RecordAccessController.SObjectOption opt2 = new RecordAccessController.SObjectOption();
    opt2.label = 'Alpha';
    RecordAccessController.SObjectOption opt3 = new RecordAccessController.SObjectOption();
    opt3.label = null;

    Test.startTest();
    System.assert(opt1.compareTo(opt2) > 0, 'Beta should be after Alpha');
    System.assert(opt2.compareTo(opt1) < 0, 'Alpha should be before Beta');
    System.assert(opt3.compareTo(opt1) > 0, 'Null label should sort after');
    System.assert(opt1.compareTo(opt3) < 0, 'Non-null label should sort before null');
    Test.stopTest();
  }
}