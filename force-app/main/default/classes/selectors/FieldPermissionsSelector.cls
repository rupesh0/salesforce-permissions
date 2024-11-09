public with sharing class FieldPermissionsSelector implements IFieldPermissionsSelector {
  public static final Dependency impl = new Dependency(
    FieldPermissionsSelector.class
  );

  public static IFieldPermissionsSelector newInstance() {
    return (IFieldPermissionsSelector) impl.newInstance();
  }

  public List<FieldPermissions> getPermissionsByPermissionRequest(
    PermissionRequest request
  ) {
    return [
      SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
      FROM FieldPermissions
      WHERE
        (ParentId IN :request.permissionSetIds
        OR Parent.ProfileId IN :request.profileIds)
        AND SobjectType IN :request.objectApiNames
    ];
  }
}
