public with sharing class SetupEntityAccessSelector implements SetupEntityAccessISelector {
  public static final Dependency impl = new Dependency(
    SetupEntityAccessSelector.class
  );

  public static SetupEntityAccessISelector newInstance() {
    return (SetupEntityAccessISelector) impl.newInstance();
  }

  public Set<Id> getAssignedApps(Set<Id> permissionSetIds) {
    Set<Id> assignedAppIds = new Set<Id>();

    for (SetupEntityAccess sea : [
      SELECT SetupEntityId
      FROM SetupEntityAccess
      WHERE ParentId IN :permissionSetIds AND SetupEntityType = 'TabSet'
    ]) {
      assignedAppIds.add(sea.SetupEntityId);
    }

    return assignedAppIds;
  }
}
