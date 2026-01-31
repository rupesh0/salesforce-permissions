public with sharing class NamedCredentialController {
  @AuraEnabled(cacheable=true)
  public static List<NamedCredentialWrapper> getNamedCredentialPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
      profileIds,
      permissionSetIds
    );

    List<SetupEntityAccess> setupEntityAccesses = [
      SELECT SetupEntityId
      FROM SetupEntityAccess
      WHERE
        SetupEntityType = 'NamedCredential'
        AND ParentId IN :unifiedPermissionSetIds
    ];

    Set<Id> setupEntityIds = new Set<Id>();
    for (SetupEntityAccess sea : setupEntityAccesses) {
      setupEntityIds.add(sea.SetupEntityId);
    }

    List<NamedCredentialWrapper> namedCredentials = new List<NamedCredentialWrapper>();
    for (NamedCredential nc : [
      SELECT Id, DeveloperName
      FROM NamedCredential
      WHERE Id IN :setupEntityIds
    ]) {
      namedCredentials.add(new NamedCredentialWrapper(nc.Id, nc.DeveloperName));
    }

    return namedCredentials;
  }

  public with sharing class NamedCredentialWrapper {
    @AuraEnabled
    public String namedCredentialId { get; set; }
    @AuraEnabled
    public String namedCredentialName { get; set; }

    public NamedCredentialWrapper(
      String namedCredentialId,
      String namedCredentialName
    ) {
      this.namedCredentialId = namedCredentialId;
      this.namedCredentialName = namedCredentialName;
    }
  }
}
