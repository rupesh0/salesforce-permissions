public with sharing class PermissionSetSelector implements IPermissionSetSelector {
  public static final Dependency impl = new Dependency(
    PermissionSetSelector.class
  );

  public static IPermissionSetSelector newInstance() {
    return (IPermissionSetSelector) impl.newInstance();
  }

  public List<PermissionSet> getAllPermissionSets() {
    return [
      SELECT Id, label
      FROM PermissionSet
      WHERE IsOwnedByProfile = FALSE
    ];
  }

  public List<PermissionSet> getCurrentUsersPermissionSets() {
    return [
      SELECT Id, label
      FROM PermissionSet
      WHERE
        IsOwnedByProfile = FALSE
        AND Id IN (
          SELECT PermissionSetId
          FROM PermissionSetAssignment
          WHERE AssigneeId = :UserInfo.getUserId()
        )
    ];
  }

  public Set<Id> getPermissionSetIdsByProfileIds(List<Id> profileIds) {
    List<PermissionSet> permissionSets = [
      SELECT Id
      FROM PermissionSet
      WHERE IsOwnedByProfile = TRUE AND ProfileId IN :profileIds
    ];

    return new Map<Id, PermissionSet>(permissionSets).keySet();
  }
}
