@IsTest
private class SetupAuditTrailControllerTest {
  @IsTest
  static void testGetRecentSecurityAuditTrails() {
    Test.startTest();
    List<String> sections = SetupAuditTrailController.getAuditTrailSections();
    System.assertNotEquals(null, sections, 'Sections list should not be null');

    String testSec = !sections.isEmpty() ? sections[0] : 'Manage Users';

    List<SetupAuditTrailController.AuditTrailDTO> allTrails = SetupAuditTrailController.getRecentSecurityAuditTrails(
      'ALL',
      ''
    );
    System.assertNotEquals(null, allTrails, 'Result should not be null');

    // Test with specific section filter
    List<SetupAuditTrailController.AuditTrailDTO> filteredTrails = SetupAuditTrailController.getRecentSecurityAuditTrails(
      testSec,
      ''
    );
    System.assertNotEquals(
      null,
      filteredTrails,
      'Filtered result should not be null'
    );

    // Test with non-matching section filter
    List<SetupAuditTrailController.AuditTrailDTO> noSecTrails = SetupAuditTrailController.getRecentSecurityAuditTrails(
      'NonExistentSectionXYZ',
      ''
    );
    System.assertEquals(
      0,
      noSecTrails.size(),
      'Should return 0 for non-matching section'
    );

    // Test with matching search term if trails exist
    if (!allTrails.isEmpty()) {
      String snippet = allTrails[0].display != null &&
        allTrails[0].display.length() >= 3
        ? allTrails[0].display.substring(0, 3)
        : 'a';
      List<SetupAuditTrailController.AuditTrailDTO> searchTrails = SetupAuditTrailController.getRecentSecurityAuditTrails(
        'ALL',
        snippet
      );
      System.assertNotEquals(
        null,
        searchTrails,
        'Search result should not be null'
      );
    }

    // Test with non-matching search term
    List<SetupAuditTrailController.AuditTrailDTO> noMatch = SetupAuditTrailController.getRecentSecurityAuditTrails(
      'ALL',
      'NonExistentXYZSearchString12345'
    );
    System.assertEquals(
      0,
      noMatch.size(),
      'Should return 0 for non-matching search term'
    );
    Test.stopTest();
  }

  @IsTest
  static void testGetAuditTrailSections() {
    Test.startTest();
    List<String> sections = SetupAuditTrailController.getAuditTrailSections();
    System.assertNotEquals(null, sections, 'Sections list should not be null');

    SetupAuditTrailController.AuditTrailDTO dto = new SetupAuditTrailController.AuditTrailDTO();
    dto.id = '0Aa000000000000AAA';
    dto.action = 'create';
    dto.section = 'Manage Users';
    dto.createdDate = DateTime.now();
    dto.createdDateFormatted = '2026-09-20 10:00:00';
    dto.createdByName = 'Admin';
    dto.display = 'Test Display';
    dto.delegateUser = 'Delegate';
    System.assertEquals('create', dto.action);
    Test.stopTest();
  }
}
