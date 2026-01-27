public with sharing class AssignedConnectedAppController {
  @AuraEnabled(cacheable=true)
  public static List<AssignedConnectedAppWrapper> getAssignedConnectedAppPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<AssignedConnectedAppWrapper> assignedConnectedApps = new List<AssignedConnectedAppWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );
      List<SetupEntityAccess> setupEntityAccesses = [
        SELECT SetupEntityId
        FROM SetupEntityAccess
        WHERE
          ParentId IN :unifiedPermissionSetIds
          AND SetupEntityType = 'ConnectedApplication'
      ];

      Set<Id> setupEntityIds = new Set<Id>();
      for (SetupEntityAccess sea : setupEntityAccesses) {
        setupEntityIds.add(sea.SetupEntityId);
      }

      List<ConnectedApplication> connectedApplications = [
        SELECT Id, Name
        FROM ConnectedApplication
        WHERE Id IN :setupEntityIds
      ];

      for (ConnectedApplication connectedApp : connectedApplications) {
        assignedConnectedApps.add(
          new AssignedConnectedAppWrapper(connectedApp.Id, connectedApp.Name)
        );
      }

      return assignedConnectedApps;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class AssignedConnectedAppWrapper {
    @AuraEnabled
    public String appId { get; set; }
    @AuraEnabled
    public String label { get; set; }

    public AssignedConnectedAppWrapper(String appId, String label) {
      this.appId = appId;
      this.label = label;
    }
  }
}
