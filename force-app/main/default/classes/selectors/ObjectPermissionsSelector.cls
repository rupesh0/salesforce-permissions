public with sharing class ObjectPermissionsSelector implements IObjectPermissionsSelector {
  public static final Dependency impl = new Dependency(
    ObjectPermissionsSelector.class
  );

  public static IObjectPermissionsSelector newInstance() {
    return (IObjectPermissionsSelector) impl.newInstance();
  }

  public List<ObjectPermissions> getPermissionsByPermissionRequest(
    PermissionRequest request
  ) {
    return [
      SELECT
        SobjectType,
        PermissionsRead,
        PermissionsCreate,
        PermissionsEdit,
        PermissionsDelete,
        PermissionsViewAllRecords,
        PermissionsModifyAllRecords
      FROM ObjectPermissions
      WHERE
        (ParentId IN :request.permissionSetIds
        OR Parent.ProfileId IN :request.profileIds)
        AND SobjectType IN :request.objectApiNames
    ];
  }
}
