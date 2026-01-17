public with sharing class AssignedAppPermissionsController {
  @AuraEnabled(cacheable=true)
  public static List<AssignedAppPermissionWrapper> getAssignedAppPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<AssignedAppPermissionWrapper> assignedAppPermissions = new List<AssignedAppPermissionWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );
      Set<Id> assignedAppIds = SetupEntityAccessSelector.newInstance()
        .getAssignedApps(unifiedPermissionSetIds);

      List<AppMenuItem> appMenus = [
        SELECT ApplicationId, Label
        FROM AppMenuItem
        WHERE ApplicationId IN :assignedAppIds
      ];

      for (AppMenuItem appMenu : appMenus) {
        assignedAppPermissions.add(
          new AssignedAppPermissionWrapper(appMenu.ApplicationId, appMenu.Label)
        );
      }

      return assignedAppPermissions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class AssignedAppPermissionWrapper {
    @AuraEnabled
    public String appId { get; set; }
    @AuraEnabled
    public String label { get; set; }

    public AssignedAppPermissionWrapper(String appId, String label) {
      this.appId = appId;
      this.label = label;
    }
  }
}
