@IsTest
private class RecordAccessControllerTest {
  @IsTest
  static void testGetSearchableSObjects() {
    Test.startTest();
    List<RecordAccessController.SObjectOption> options = RecordAccessController.getSearchableSObjects();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
    System.assert(
      options.size() > 0,
      'Should find at least one searchable sObject'
    );
  }

  @IsTest
  static void testSearchRecords() {
    Account acc = new Account(Name = 'Test Record Access Account');
    insert acc;

    Test.startTest();
    // Test with blank object name
    List<RecordAccessController.RecordOption> emptyObjResults = RecordAccessController.searchRecords(
      '',
      'Test'
    );
    System.assertEquals(
      0,
      emptyObjResults.size(),
      'Should return empty for blank object name'
    );

    // Test with invalid object name
    List<RecordAccessController.RecordOption> invalidObjResults = RecordAccessController.searchRecords(
      'Invalid_NonExistent_Object__xyz',
      'Test'
    );
    System.assertEquals(
      0,
      invalidObjResults.size(),
      'Should return empty for invalid object name'
    );

    // Test search by name
    List<RecordAccessController.RecordOption> nameResults = RecordAccessController.searchRecords(
      'Account',
      'Test Record Access'
    );
    System.assert(nameResults.size() > 0, 'Should find account by name');

    // Test search by ID
    List<RecordAccessController.RecordOption> idResults = RecordAccessController.searchRecords(
      'Account',
      acc.Id
    );
    System.assert(idResults.size() > 0, 'Should find account by ID');
    System.assertEquals(acc.Id, idResults[0].id, 'Record ID should match');

    // Test search with empty string
    List<RecordAccessController.RecordOption> blankTermResults = RecordAccessController.searchRecords(
      'Account',
      ''
    );
    System.assert(
      blankTermResults.size() > 0,
      'Should return records on blank search term'
    );
    Test.stopTest();
  }

  @IsTest
  static void testSearchUsers() {
    User currentUser = [
      SELECT Id, Name, Username
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    Test.startTest();
    List<RecordAccessController.UserOption> allUsers = RecordAccessController.searchUsers(
      ''
    );
    System.assert(allUsers.size() > 0, 'Should return users on empty query');

    List<RecordAccessController.UserOption> specificUsers = RecordAccessController.searchUsers(
      currentUser.Name
    );
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
    RecordAccessController.RecordAccessMatrixDTO emptyResult = RecordAccessController.checkRecordAccess(
      null,
      null
    );
    System.assertEquals(
      null,
      emptyResult.rows,
      'Empty input should return empty matrix'
    );

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
    System.assert(
      matrix.rows[0].userAccess.containsKey(String.valueOf(currentUserId)),
      'User access map should contain user'
    );
  }

  @IsTest
  static void testGetRecordSharingDetails() {
    Account acc = new Account(Name = 'Test Sharing Account');
    insert acc;
    Id currentUserId = UserInfo.getUserId();

    Test.startTest();
    // Test with null inputs
    RecordAccessController.RecordSharingExplanationDTO emptyDTO = RecordAccessController.getRecordSharingDetails(
      null,
      null
    );
    System.assertEquals(
      null,
      emptyDTO.userExplanations,
      'Null inputs should return empty explanation'
    );

    // Test with valid inputs
    RecordAccessController.RecordSharingExplanationDTO details = RecordAccessController.getRecordSharingDetails(
      acc.Id,
      new List<Id>{ currentUserId }
    );

    System.assertNotEquals(null, details, 'Details should not be null');
    System.assertEquals(acc.Id, details.recordId, 'Record ID should match');
    System.assertNotEquals(
      null,
      details.userExplanations,
      'User explanations should not be null'
    );
    System.assert(
      details.userExplanations.size() > 0,
      'Should have explanation for current user'
    );

    // Also test with a Case record to exercise Case share fields
    Case c = new Case(Subject = 'Test Case Record Access');
    insert c;
    RecordAccessController.RecordSharingExplanationDTO caseDetails = RecordAccessController.getRecordSharingDetails(
      c.Id,
      new List<Id>{ currentUserId }
    );
    System.assertNotEquals(
      null,
      caseDetails,
      'Case details should not be null'
    );
    System.assertEquals(
      c.Id,
      caseDetails.recordId,
      'Case Record ID should match'
    );
    Test.stopTest();
  }

  @IsTest
  static void testSharingDetailsComprehensive() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User testUser = new User(
      Alias = 'tcompr',
      Email = 'tuser_compr@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'TestingCompr',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'tuser_compr_' + DateTime.now().getTime() + '@testorg.com'
    );
    insert testUser;

    List<Class__c> classes = [SELECT Id FROM Class__c LIMIT 1];
    Id targetId;
    String targetObj = 'Class__c';
    if (!classes.isEmpty()) {
      targetId = classes[0].Id;
      // Grant manual share
      RecordAccessController.grantManualShare(
        'Class__c',
        targetId,
        testUser.Id,
        'Read'
      );
    } else {
      Account acc = new Account(Name = 'Compr Sharing Acc');
      insert acc;
      targetId = acc.Id;
      targetObj = 'Account';
    }

    Test.startTest();
    RecordAccessController.RecordSharingExplanationDTO details = RecordAccessController.getRecordSharingDetails(
      targetId,
      new List<Id>{ UserInfo.getUserId(), testUser.Id }
    );
    System.assertNotEquals(null, details, 'Details should not be null');
    System.assertEquals(
      2,
      details.userExplanations.size(),
      'Should have explanations for both users'
    );
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
    System.assert(
      opt1.compareTo(opt3) < 0,
      'Non-null label should sort before null'
    );
    Test.stopTest();
  }

  @IsTest
  static void testDescribeCacheService() {
    Test.startTest();
    DescribeCacheService.put('testKey', 'testValue', 60);
    Object val = DescribeCacheService.get('testKey');
    System.assertEquals(
      'testValue',
      (String) val,
      'Value should match cached item'
    );

    DescribeCacheService.remove('testKey');
    Object afterRemove = DescribeCacheService.get('testKey');
    System.assertEquals(null, afterRemove, 'Value should be null after remove');
    Test.stopTest();
  }

  @IsTest
  static void testGrantAndRevokeManualShare() {
    // Find or create a test standard user
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User testUser = new User(
      Alias = 'tusr',
      Email = 'tuser_share@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'TestingShare',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'tuser_share_' + DateTime.now().getTime() + '@testorg.com'
    );
    insert testUser;

    // Check if Class__c exists for private sharing test
    List<Class__c> classes = [SELECT Id FROM Class__c LIMIT 1];
    Id targetRecordId;
    String targetSObj = 'Class__c';
    if (!classes.isEmpty()) {
      targetRecordId = classes[0].Id;
    } else {
      // Fallback: create Account record to test public OWD validation
      Account a = new Account(Name = 'Test Fallback Account');
      insert a;
      targetRecordId = a.Id;
      targetSObj = 'Account';
    }

    Test.startTest();
    if (targetSObj == 'Class__c') {
      // 1. Grant Edit manual share
      RecordAccessController.RemediationResultDTO grantRes = RecordAccessController.grantManualShare(
        'Class__c',
        targetRecordId,
        testUser.Id,
        'Edit'
      );
      System.assertNotEquals(null, grantRes, 'Result should not be null');
      System.assert(
        grantRes.isSuccess,
        'Grant should succeed on private custom object'
      );

      // 2. Update existing manual share to Read
      RecordAccessController.RemediationResultDTO updateRes = RecordAccessController.grantManualShare(
        'Class__c',
        targetRecordId,
        testUser.Id,
        'Read'
      );
      System.assert(updateRes.isSuccess, 'Update to Read should succeed');

      // 3. Revoke manual share
      RecordAccessController.RemediationResultDTO revokeRes = RecordAccessController.revokeManualShare(
        'Class__c',
        targetRecordId,
        testUser.Id
      );
      System.assert(revokeRes.isSuccess, 'Revoke should succeed');

      // 4. Revoke again should report none found
      RecordAccessController.RemediationResultDTO revokeAgain = RecordAccessController.revokeManualShare(
        'Class__c',
        targetRecordId,
        testUser.Id
      );
      System.assertEquals(
        false,
        revokeAgain.isSuccess,
        'Second revoke should return false'
      );
    } else {
      // Test Public Read/Write handling on Account
      RecordAccessController.RemediationResultDTO res = RecordAccessController.grantManualShare(
        'Account',
        targetRecordId,
        testUser.Id,
        'Read'
      );
      System.assertNotEquals(null, res, 'Result should not be null');
    }
    Test.stopTest();
  }

  @IsTest
  static void testManualShareErrorHandling() {
    Test.startTest();
    // Missing parameters
    try {
      RecordAccessController.grantManualShare('', null, null, '');
      System.assert(false, 'Should throw AuraHandledException on blank params');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    try {
      RecordAccessController.revokeManualShare('', null, null);
      System.assert(false, 'Should throw AuraHandledException on blank params');
    } catch (AuraHandledException e) {
      System.assert(true);
    }

    // Unsupported object
    Account a = new Account(Name = 'Error Test Account');
    insert a;
    RecordAccessController.RemediationResultDTO unsuppRes = RecordAccessController.grantManualShare(
      'NonExistent_SObject__xyz',
      a.Id,
      UserInfo.getUserId(),
      'Read'
    );
    System.assertEquals(
      false,
      unsuppRes.isSuccess,
      'Should fail for unsupported object'
    );

    RecordAccessController.RemediationResultDTO revokeUnsupp = RecordAccessController.revokeManualShare(
      'NonExistent_SObject__xyz',
      a.Id,
      UserInfo.getUserId()
    );
    System.assertEquals(
      false,
      revokeUnsupp.isSuccess,
      'Should fail for unsupported object'
    );
    Test.stopTest();
  }

  @IsTest
  static void testAdditionalObjectsAndDtoCoverage() {
    // 1. Test DTO Instantiations
    RecordAccessController.UserHeaderDTO uh = new RecordAccessController.UserHeaderDTO();
    uh.userId = UserInfo.getUserId();
    uh.userName = 'Test User';
    uh.profileName = 'Standard User';
    uh.setupUserUrl =
      '/lightning/setup/ManageUsers/page?address=%2F' + uh.userId;

    RecordAccessController.AccessDTO accDto = new RecordAccessController.AccessDTO();
    accDto.hasReadAccess = true;
    accDto.hasEditAccess = true;
    accDto.maxAccessLevel = 'All';

    RecordAccessController.RecordRowDTO rowDto = new RecordAccessController.RecordRowDTO();
    rowDto.recordId = UserInfo.getUserId();
    rowDto.recordName = 'Row Name';
    rowDto.sObjectName = 'User';
    rowDto.sObjectLabel = 'User';
    rowDto.recordUrl = '/lightning/r/User/' + rowDto.recordId + '/view';
    rowDto.userAccess = new Map<String, RecordAccessController.AccessDTO>{
      String.valueOf(uh.userId) => accDto
    };

    RecordAccessController.SharingReasonDTO sr = new RecordAccessController.SharingReasonDTO(
      'Manual Sharing',
      'Read',
      'Test Details'
    );
    sr.isManualShare = true;
    sr.shareRecordId = '00a000000000000AAA';
    System.assertEquals('Manual Sharing', sr.category, 'Category should match');
    System.assertEquals(true, sr.isManualShare, 'isManualShare should match');

    RecordAccessController.UserSharingDetailDTO ue = new RecordAccessController.UserSharingDetailDTO();
    ue.userId = UserInfo.getUserId();
    ue.userName = 'Test User';
    ue.profileName = 'Standard';
    ue.overallAccess = 'Read/Write';
    ue.setupUserUrl =
      '/lightning/setup/ManageUsers/page?address=%2F' + ue.userId;
    ue.recordUrl = '/lightning/r/Account/001000000000000AAA/view';
    ue.reasons = new List<RecordAccessController.SharingReasonDTO>{ sr };

    RecordAccessController.RecordSharingExplanationDTO expDto = new RecordAccessController.RecordSharingExplanationDTO();
    expDto.recordId = UserInfo.getUserId();
    expDto.recordName = 'Record Name';
    expDto.sObjectName = 'Account';
    expDto.sObjectLabel = 'Account';
    expDto.ownerId = UserInfo.getUserId();
    expDto.ownerName = 'Owner Name';
    expDto.internalSharingModel = 'Private';
    expDto.userExplanations = new List<RecordAccessController.UserSharingDetailDTO>{
      ue
    };

    RecordAccessController.RemediationResultDTO remDto = new RecordAccessController.RemediationResultDTO(
      true,
      'Success Message',
      '00a000000000000AAA'
    );
    System.assertEquals(true, remDto.isSuccess, 'Success should be true');

    // 2. Test DescribeCacheService nulls
    DescribeCacheService.put(null, null, null);
    DescribeCacheService.get(null);
    DescribeCacheService.remove(null);

    // 3. Test Opportunity and Contact sharing details
    Opportunity opp = new Opportunity(
      Name = 'Test Sharing Opp',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert opp;

    Contact con = new Contact(LastName = 'Test Sharing Contact');
    insert con;

    Lead ld = new Lead(LastName = 'Test Sharing Lead', Company = 'Acme Corp');
    insert ld;

    Test.startTest();
    RecordAccessController.RecordSharingExplanationDTO oppDetails = RecordAccessController.getRecordSharingDetails(
      opp.Id,
      new List<Id>{ UserInfo.getUserId() }
    );
    System.assertNotEquals(null, oppDetails, 'Opp details should not be null');

    RecordAccessController.RecordSharingExplanationDTO conDetails = RecordAccessController.getRecordSharingDetails(
      con.Id,
      new List<Id>{ UserInfo.getUserId() }
    );
    System.assertNotEquals(
      null,
      conDetails,
      'Contact details should not be null'
    );

    RecordAccessController.RecordSharingExplanationDTO ldDetails = RecordAccessController.getRecordSharingDetails(
      ld.Id,
      new List<Id>{ UserInfo.getUserId() }
    );
    System.assertNotEquals(null, ldDetails, 'Lead details should not be null');
    Test.stopTest();
  }
}
