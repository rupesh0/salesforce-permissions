public with sharing class VFPagePermissionsController {
  @AuraEnabled(cacheable=true)
  public static List<VFPagePermissionWrapper> getVFPagePermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
      profileIds,
      permissionSetIds
    );

    List<SetupEntityAccess> setupEntityAccesses = [
      SELECT SetupEntityId
      FROM SetupEntityAccess
      WHERE
        ParentId IN :unifiedPermissionSetIds
        AND SetupEntityType = 'ApexPage'
    ];

    Set<Id> setupEntityIds = new Set<Id>();
    for (SetupEntityAccess sea : setupEntityAccesses) {
      setupEntityIds.add(sea.SetupEntityId);
    }

    List<VFPagePermissionWrapper> vfPages = new List<VFPagePermissionWrapper>();
    for (ApexPage page : [
      SELECT Id, Name, NamespacePrefix
      FROM ApexPage
      WHERE Id IN :setupEntityIds
    ]) {
      vfPages.add(new VFPagePermissionWrapper(page));
    }

    return vfPages;
  }

  public with sharing class VFPagePermissionWrapper {
    @AuraEnabled
    public String vfPageName { get; set; }

    @AuraEnabled
    public String namespacePrefix { get; set; }

    @AuraEnabled
    public String pageId { get; set; }

    public VFPagePermissionWrapper(ApexPage page) {
      this.vfPageName = page.Name;
      this.namespacePrefix = page.NamespacePrefix;
      this.pageId = page.Id;
    }
  }
}
