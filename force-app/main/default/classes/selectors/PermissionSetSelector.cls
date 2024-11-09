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
}
