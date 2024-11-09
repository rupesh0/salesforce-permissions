public interface IPermissionSetSelector {
  List<PermissionSet> getAllPermissionSets();
  List<PermissionSet> getCurrentUsersPermissionSets();
}
