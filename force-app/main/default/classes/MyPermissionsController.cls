public with sharing class MyPermissionsController {
  @AuraEnabled
  public static PermissionDetail getCurrentUsersDetails() {
    try {
      PermissionDetail pd = new PermissionDetail();
      pd.currentUsersProfileId = UserInfo.getProfileId();
      pd.currentUsersPermissionSetIds = new List<Id>{};

      for (PermissionSet ps : [
        SELECT Id
        FROM PermissionSet
        WHERE
          IsCustom = TRUE
          AND Id IN (
            SELECT PermissionSetId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
          )
      ]) {
        pd.currentUsersPermissionSetIds.add(ps.Id);
      }

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
