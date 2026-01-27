public with sharing class ApexClassPermissionsController {
  @AuraEnabled(cacheable=true)
  public static List<ApexClassPermissionWrapper> getApexClassPermissions(
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
        AND SetupEntityType = 'ApexClass'
    ];

    Set<Id> setupEntityIds = new Set<Id>();
    for (SetupEntityAccess sea : setupEntityAccesses) {
      setupEntityIds.add(sea.SetupEntityId);
    }

    List<ApexClass> apexClasses = [
      SELECT Id, Name, NamespacePrefix
      FROM ApexClass
      WHERE Id IN :setupEntityIds
    ];

    List<ApexClassPermissionWrapper> apexClassPermissionsList = new List<ApexClassPermissionWrapper>();
    for (ApexClass apexClass : apexClasses) {
      apexClassPermissionsList.add(
        new ApexClassPermissionWrapper(
          apexClass.Id,
          apexClass.Name,
          apexClass.NamespacePrefix
        )
      );
    }

    return apexClassPermissionsList;
  }

  public class ApexClassPermissionWrapper {
    @AuraEnabled
    public String classId { get; set; }
    @AuraEnabled
    public String className { get; set; }
    @AuraEnabled
    public String namespace { get; set; }

    public ApexClassPermissionWrapper(
      String classId,
      String className,
      String namespace
    ) {
      this.classId = classId;
      this.className = className;
      this.namespace = namespace;
    }
  }
}
