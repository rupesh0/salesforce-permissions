public interface IPermissionSetSelector {
  List<PermissionSet> getAllPermissionSets();
  List<PermissionSet> getCurrentUsersPermissionSets();
  Set<Id> getPermissionSetIdsByProfileIds(List<Id> profileIds);
}
