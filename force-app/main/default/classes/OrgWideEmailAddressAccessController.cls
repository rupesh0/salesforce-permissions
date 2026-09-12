public with sharing class OrgWideEmailAddressAccessController {
  @AuraEnabled(cacheable=true)
  public static List<OrgWideEmailAddressWrapper> getOrgWideEmailAddressPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<OrgWideEmailAddressWrapper> orgWideEmails = new List<OrgWideEmailAddressWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );

      List<SetupEntityAccess> setupEntityAccesses = [
        SELECT SetupEntityId
        FROM SetupEntityAccess
        WHERE
          SetupEntityType = 'OrgWideEmailAddress'
          AND ParentId IN :unifiedPermissionSetIds
      ];

      Set<Id> setupEntityIds = new Set<Id>();
      for (SetupEntityAccess sea : setupEntityAccesses) {
        setupEntityIds.add(sea.SetupEntityId);
      }

      for (OrgWideEmailAddress owea : [
        SELECT Id, DisplayName, Address, Purpose
        FROM OrgWideEmailAddress
        WHERE Id IN :setupEntityIds
      ]) {
        orgWideEmails.add(
          new OrgWideEmailAddressWrapper(
            owea.Id,
            owea.DisplayName,
            owea.Address,
            owea.Purpose
          )
        );
      }

      return orgWideEmails;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class OrgWideEmailAddressWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String displayName { get; set; }
    @AuraEnabled
    public String address { get; set; }
    @AuraEnabled
    public String purpose { get; set; }

    public OrgWideEmailAddressWrapper(
      String id,
      String displayName,
      String address,
      String purpose
    ) {
      this.id = id;
      this.displayName = displayName;
      this.address = address;
      this.purpose = purpose;
    }
  }
}
