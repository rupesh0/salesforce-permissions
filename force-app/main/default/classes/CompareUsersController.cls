public with sharing class CompareUsersController {
  @AuraEnabled(cacheable=true)
  public static List<UserOption> searchUsers(String searchTerm) {
    try {
      String searchKey = String.isBlank(searchTerm)
        ? '%'
        : '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';

      List<User> users = [
        SELECT Id, Name, Username, Profile.Name
        FROM User
        WHERE
          IsActive = TRUE
          AND (Name LIKE :searchKey
          OR Username LIKE :searchKey)
        ORDER BY Name
        LIMIT 20
      ];

      List<UserOption> options = new List<UserOption>();
      for (User u : users) {
        UserOption opt = new UserOption();
        opt.id = u.Id;
        opt.name = u.Name;
        opt.username = u.Username;
        opt.profileName = u.Profile != null ? u.Profile.Name : '';
        options.add(opt);
      }
      return options;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static UserPermissionDetail getUserPermissionDetails(Id userId) {
    if (userId == null) {
      return null;
    }
    try {
      List<User> users = [
        SELECT Id, Name, ProfileId, Profile.Name
        FROM User
        WHERE Id = :userId
        LIMIT 1
      ];

      if (users.isEmpty()) {
        return null;
      }

      User u = users[0];
      List<PermissionSetAssignment> assignments = [
        SELECT PermissionSetId
        FROM PermissionSetAssignment
        WHERE AssigneeId = :userId AND PermissionSet.IsOwnedByProfile = FALSE
      ];

      List<Id> psIds = new List<Id>();
      for (PermissionSetAssignment psa : assignments) {
        psIds.add(psa.PermissionSetId);
      }

      UserPermissionDetail detail = new UserPermissionDetail();
      detail.userId = u.Id;
      detail.userName = u.Name;
      detail.profileId = u.ProfileId;
      detail.profileName = u.Profile != null ? u.Profile.Name : '';
      detail.permissionSetIds = psIds;
      detail.permissionSetCount = psIds.size();

      return detail;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public with sharing class UserOption {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String profileName;
  }

  public with sharing class UserPermissionDetail {
    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public String userName;
    @AuraEnabled
    public Id profileId;
    @AuraEnabled
    public String profileName;
    @AuraEnabled
    public List<Id> permissionSetIds;
    @AuraEnabled
    public Integer permissionSetCount;
  }
}
