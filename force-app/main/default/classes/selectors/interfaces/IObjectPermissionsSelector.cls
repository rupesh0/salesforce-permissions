public interface IObjectPermissionsSelector {
  List<ObjectPermissions> getPermissionsByPermissionRequest(
    PermissionRequest request
  );
}
