public with sharing class ExternalDataSourceController {
  @AuraEnabled(cacheable=true)
  public static List<ExternalDataSourceWrapper> getExternalDataSourcePermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<ExternalDataSourceWrapper> ExternalDataSources = new List<ExternalDataSourceWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );
      List<SetupEntityAccess> setupEntityAccesses = [
        SELECT SetupEntityId
        FROM SetupEntityAccess
        WHERE
          SetupEntityType = 'ExternalDataSource'
          AND ParentId IN :unifiedPermissionSetIds
      ];

      Set<Id> setupEntityIds = new Set<Id>();
      for (SetupEntityAccess sea : setupEntityAccesses) {
        setupEntityIds.add(sea.SetupEntityId);
      }

      for (ExternalDataSource externalDataSource : [
        SELECT Id, DeveloperName
        FROM ExternalDataSource
        WHERE Id IN :setupEntityIds
      ]) {
        ExternalDataSources.add(
          new ExternalDataSourceWrapper(
            externalDataSource.Id,
            externalDataSource.DeveloperName
          )
        );
      }

      return ExternalDataSources;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class ExternalDataSourceWrapper {
    @AuraEnabled
    public String externalDataSourceId { get; set; }
    @AuraEnabled
    public String label { get; set; }

    public ExternalDataSourceWrapper(
      String externalDataSourceId,
      String label
    ) {
      this.externalDataSourceId = externalDataSourceId;
      this.label = label;
    }
  }
}
