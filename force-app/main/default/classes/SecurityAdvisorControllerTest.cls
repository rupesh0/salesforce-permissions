@IsTest
private class SecurityAdvisorControllerTest {
  @TestSetup
  static void setupTestData() {
    // Query Standard User profile and System Administrator profile
    Profile standardProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];
    Profile adminProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];

    // Create an active standard user
    User activeUser = new User(
      FirstName = 'Active',
      LastName = 'SecUser',
      Email = 'activesecuser@testorg.com',
      Username = 'activesecuser' + DateTime.now().getTime() + '@testorg.com',
      Alias = 'asecu',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = standardProfile.Id,
      LanguageLocaleKey = 'en_US',
      IsActive = true
    );
    insert activeUser;

    // Create an inactive user
    User inactiveUser = new User(
      FirstName = 'Inactive',
      LastName = 'SecUser',
      Email = 'inactivesecuser@testorg.com',
      Username = 'inactivesecuser' + DateTime.now().getTime() + '@testorg.com',
      Alias = 'isecu',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = standardProfile.Id,
      LanguageLocaleKey = 'en_US',
      IsActive = false
    );
    insert inactiveUser;

    // Create custom Permission Sets
    // 1. Privileged permission set
    PermissionSet privPS = new PermissionSet(
      Name = 'Test_Priv_PS_' + DateTime.now().getTime(),
      Label = 'Test Privileged PS',
      PermissionsAuthorApex = true,
      PermissionsModifyMetadata = true,
      PermissionsViewRoles = true,
      PermissionsViewSetup = true
    );
    insert privPS;

    // 2. Dormant permission set (no assignments)
    PermissionSet dormantPS = new PermissionSet(
      Name = 'Test_Dorm_PS_' + DateTime.now().getTime(),
      Label = 'Test Dormant PS'
    );
    insert dormantPS;

    // 3. Redundant Admin permission set
    PermissionSet redundantPS = new PermissionSet(
      Name = 'Test_Redun_PS_' + DateTime.now().getTime(),
      Label = 'Test Redundant PS',
      PermissionsAuthorApex = true,
      PermissionsModifyMetadata = true,
      PermissionsViewRoles = true,
      PermissionsViewSetup = true
    );
    insert redundantPS;

    // Assign privileged PS to active user
    insert new PermissionSetAssignment(
      AssigneeId = activeUser.Id,
      PermissionSetId = privPS.Id
    );

    // Assign dormant PS to inactive user (so it creates an inactive user assignment)
    insert new PermissionSetAssignment(
      AssigneeId = inactiveUser.Id,
      PermissionSetId = privPS.Id
    );

    // Assign redundant PS to current running user (System Administrator)
    User currentUser = [
      SELECT Id, Profile.Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    if (currentUser.Profile.Name == 'System Administrator') {
      insert new PermissionSetAssignment(
        AssigneeId = currentUser.Id,
        PermissionSetId = redundantPS.Id
      );
    }
  }

  @IsTest
  static void testGetSecurityHealthSummary() {
    Test.startTest();
    SecurityAdvisorController.HealthSummaryDTO summary = SecurityAdvisorController.getSecurityHealthSummary();
    Test.stopTest();

    System.assertNotEquals(null, summary, 'Summary should not be null');
    System.assert(
      summary.overallScore >= 0 && summary.overallScore <= 100,
      'Score should be between 0 and 100'
    );
    System.assertNotEquals(
      null,
      summary.healthGrade,
      'Grade should not be null'
    );
    System.assertNotEquals(
      null,
      summary.scoreVariant,
      'Variant should not be null'
    );
    System.assert(
      summary.totalActiveUsers > 0,
      'Active users count should be > 0'
    );
    System.assert(
      summary.totalCustomPermissionSets > 0,
      'Custom permission sets count should be > 0'
    );
    System.assertNotEquals(
      null,
      summary.criticalFindings,
      'Critical findings should not be null'
    );
    System.assertNotEquals(
      null,
      summary.dormantSets,
      'Dormant sets should not be null'
    );
    System.assertNotEquals(
      null,
      summary.inactiveAssignments,
      'Inactive assignments should not be null'
    );
    System.assertNotEquals(
      null,
      summary.redundantAssignments,
      'Redundant assignments should not be null'
    );
  }

  @IsTest
  static void testAffectedUserComparable() {
    SecurityAdvisorController.AffectedUserDTO u1 = new SecurityAdvisorController.AffectedUserDTO();
    u1.name = 'Bob Security';
    SecurityAdvisorController.AffectedUserDTO u2 = new SecurityAdvisorController.AffectedUserDTO();
    u2.name = 'Alice Security';
    SecurityAdvisorController.AffectedUserDTO u3 = new SecurityAdvisorController.AffectedUserDTO();
    u3.name = null;

    Test.startTest();
    System.assert(u1.compareTo(u2) > 0, 'Bob should sort after Alice');
    System.assert(u2.compareTo(u1) < 0, 'Alice should sort before Bob');
    System.assert(u3.compareTo(u1) > 0, 'Null should sort after Bob');
    System.assert(u1.compareTo(u3) < 0, 'Bob should sort before Null');
    Test.stopTest();
  }

  @IsTest
  static void testDtoCoverage() {
    Test.startTest();
    SecurityAdvisorController.DormantSetDTO d = new SecurityAdvisorController.DormantSetDTO();
    d.permissionSetId = null;
    d.name = 'Dormant_Test';
    d.label = 'Dormant Test';
    d.description = 'Test Description';
    d.createdDate = DateTime.now();

    SecurityAdvisorController.InactiveUserAssignmentDTO ia = new SecurityAdvisorController.InactiveUserAssignmentDTO();
    ia.assignmentId = null;
    ia.userId = null;
    ia.userFullName = 'Inactive User';
    ia.username = 'inactive@test.com';
    ia.profileName = 'Standard User';
    ia.permissionSetId = null;
    ia.permissionSetName = 'Inactive_PS';
    ia.permissionSetLabel = 'Inactive PS';

    SecurityAdvisorController.RedundantAssignmentDTO ra = new SecurityAdvisorController.RedundantAssignmentDTO();
    ra.userId = null;
    ra.userName = 'Admin User';
    ra.profileName = 'System Administrator';
    ra.permissionSetLabel = 'Admin PS';
    ra.redundantPermission = 'Modify All Data';
    ra.reason = 'Profile already has full access';

    System.assertEquals('Dormant Test', d.label);
    System.assertEquals('Inactive PS', ia.permissionSetLabel);
    System.assertEquals('Admin PS', ra.permissionSetLabel);
    Test.stopTest();
  }
}
