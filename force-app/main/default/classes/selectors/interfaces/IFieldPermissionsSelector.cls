public interface IFieldPermissionsSelector {
  List<FieldPermissions> getPermissionsByPermissionRequest(
    PermissionRequest request
  );
}
