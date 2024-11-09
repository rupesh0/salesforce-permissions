public with sharing class MyPermissionsController {
  @AuraEnabled
  public static PermissionDetail getCurrentUsersDetails() {
    try {
      List<PermissionSet> permissionSets = PermissionSetSelector.newInstance()
        .getCurrentUsersPermissionSets();

      PermissionDetail pd = new PermissionDetail();
      pd.currentUsersProfileId = UserInfo.getProfileId();
      pd.currentUsersPermissionSetIds = new List<Id>(
        new Map<Id, PermissionSet>(permissionSets).keySet()
      );

      return pd;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public with sharing class PermissionDetail {
    @AuraEnabled
    public Id currentUsersProfileId;
    @AuraEnabled
    public List<Id> currentUsersPermissionSetIds;
  }
}
