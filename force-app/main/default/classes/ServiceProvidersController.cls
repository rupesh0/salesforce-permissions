public with sharing class ServiceProvidersController {
  @AuraEnabled(cacheable=true)
  public static List<ServiceProviderWrapper> getServiceProviderPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<ServiceProviderWrapper> serviceProviders = new List<ServiceProviderWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );

      List<SetupEntityAccess> setupEntityAccesses = [
        SELECT SetupEntityId
        FROM SetupEntityAccess
        WHERE
          SetupEntityType = 'ConnectedApplication'
          AND ParentId IN :unifiedPermissionSetIds
      ];

      Set<Id> setupEntityIds = new Set<Id>();
      for (SetupEntityAccess sea : setupEntityAccesses) {
        setupEntityIds.add(sea.SetupEntityId);
      }

      for (ConnectedApplication ca : [
        SELECT Id, Name, StartUrl
        FROM ConnectedApplication
        WHERE Id IN :setupEntityIds
      ]) {
        serviceProviders.add(
          new ServiceProviderWrapper(ca.Id, ca.Name, ca.StartUrl)
        );
      }

      return serviceProviders;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class ServiceProviderWrapper {
    @AuraEnabled
    public String serviceProviderId { get; set; }
    @AuraEnabled
    public String serviceProviderName { get; set; }
    @AuraEnabled
    public String startUrl { get; set; }

    public ServiceProviderWrapper(
      String serviceProviderId,
      String serviceProviderName,
      String startUrl
    ) {
      this.serviceProviderId = serviceProviderId;
      this.serviceProviderName = serviceProviderName;
      this.startUrl = startUrl;
    }
  }
}
