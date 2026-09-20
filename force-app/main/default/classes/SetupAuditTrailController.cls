public without sharing class SetupAuditTrailController {
  @AuraEnabled(cacheable=true)
  public static List<AuditTrailDTO> getRecentSecurityAuditTrails(
    String sectionFilter,
    String searchTerm
  ) {
    try {
      List<AuditTrailDTO> results = new List<AuditTrailDTO>();

      List<SetupAuditTrail> records = [
        SELECT
          Id,
          Action,
          Section,
          CreatedDate,
          CreatedBy.Name,
          Display,
          DelegateUser
        FROM SetupAuditTrail
        WHERE CreatedDate >= LAST_N_DAYS:7
        ORDER BY CreatedDate DESC
        LIMIT 500
      ];

      String searchLower = String.isNotBlank(searchTerm)
        ? searchTerm.toLowerCase().trim()
        : '';

      for (SetupAuditTrail t : records) {
        String disp = t.Display != null ? t.Display : '';
        String actor = t.CreatedBy != null &&
          t.CreatedBy.Name != null
          ? t.CreatedBy.Name
          : 'System';
        String act = t.Action != null ? t.Action : '';
        String sec = t.Section != null ? t.Section : '';

        // Filter by section in memory
        if (
          String.isNotBlank(sectionFilter) &&
          sectionFilter != 'ALL' &&
          sec != sectionFilter
        ) {
          continue;
        }

        // Filter by search text in memory
        if (
          String.isNotBlank(searchLower) &&
          !disp.toLowerCase().contains(searchLower) &&
          !actor.toLowerCase().contains(searchLower) &&
          !act.toLowerCase().contains(searchLower) &&
          !sec.toLowerCase().contains(searchLower)
        ) {
          continue;
        }

        AuditTrailDTO dto = new AuditTrailDTO();
        dto.id = t.Id;
        dto.action = act;
        dto.section = sec;
        dto.createdDate = t.CreatedDate;
        dto.createdDateFormatted = t.CreatedDate != null
          ? t.CreatedDate.format('yyyy-MM-dd HH:mm:ss')
          : '';
        dto.createdByName = actor;
        dto.display = disp;
        dto.delegateUser = t.DelegateUser != null ? t.DelegateUser : '';
        results.add(dto);
      }

      return results;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to query setup audit trail: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getAuditTrailSections() {
    try {
      Set<String> sections = new Set<String>();
      for (SetupAuditTrail t : [
        SELECT Section
        FROM SetupAuditTrail
        WHERE CreatedDate >= LAST_N_DAYS:7
        ORDER BY CreatedDate DESC
        LIMIT 500
      ]) {
        if (String.isNotBlank(t.Section)) {
          sections.add(t.Section);
        }
      }
      List<String> sortedSections = new List<String>(sections);
      sortedSections.sort();
      return sortedSections;
    } catch (Exception e) {
      return new List<String>{
        'Manage Users',
        'Profiles',
        'Permission Sets',
        'Sharing Settings'
      };
    }
  }

  public class AuditTrailDTO {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String action;
    @AuraEnabled
    public String section;
    @AuraEnabled
    public DateTime createdDate;
    @AuraEnabled
    public String createdDateFormatted;
    @AuraEnabled
    public String createdByName;
    @AuraEnabled
    public String display;
    @AuraEnabled
    public String delegateUser;
  }
}
