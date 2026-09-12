@IsTest
private class CompareUsersControllerTest {
  @IsTest
  static void testSearchUsersWithEmptyTerm() {
    Test.startTest();
    List<CompareUsersController.UserOption> results = CompareUsersController.searchUsers(
      ''
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(results.size() > 0, 'Should find at least one active user');
  }

  @IsTest
  static void testSearchUsersWithTerm() {
    User currentUser = [
      SELECT Id, Name, Username
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    Test.startTest();
    List<CompareUsersController.UserOption> results = CompareUsersController.searchUsers(
      currentUser.Name
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(
      results.size() > 0,
      'Should find user matching current user name'
    );
  }

  @IsTest
  static void testSearchUsersWithNonMatchingTerm() {
    Test.startTest();
    List<CompareUsersController.UserOption> results = CompareUsersController.searchUsers(
      'NonExistentUserZ9Y8X7W6V5'
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assertEquals(0, results.size(), 'Should find 0 users');
  }

  @IsTest
  static void testGetUserPermissionDetailsValidUser() {
    Id currentUserId = UserInfo.getUserId();

    Test.startTest();
    CompareUsersController.UserPermissionDetail detail = CompareUsersController.getUserPermissionDetails(
      currentUserId
    );
    Test.stopTest();

    System.assertNotEquals(null, detail, 'Detail should not be null');
    System.assertEquals(currentUserId, detail.userId, 'User ID should match');
    System.assertNotEquals(
      null,
      detail.profileId,
      'Profile ID should not be null'
    );
    System.assertNotEquals(
      null,
      detail.permissionSetIds,
      'Permission set IDs should not be null'
    );
  }

  @IsTest
  static void testGetUserPermissionDetailsNullUser() {
    Test.startTest();
    CompareUsersController.UserPermissionDetail detail = CompareUsersController.getUserPermissionDetails(
      null
    );
    Test.stopTest();

    System.assertEquals(null, detail, 'Detail should be null for null user ID');
  }

  @IsTest
  static void testGetUserPermissionDetailsNonExistentUser() {
    Id fakeUserId = Id.valueOf('005000000000000AAA');
    Test.startTest();
    CompareUsersController.UserPermissionDetail detail = CompareUsersController.getUserPermissionDetails(
      fakeUserId
    );
    Test.stopTest();

    System.assertEquals(
      null,
      detail,
      'Detail should be null for non-existent user ID'
    );
  }
}
