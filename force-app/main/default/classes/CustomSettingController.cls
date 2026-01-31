public with sharing class CustomSettingController {
  @AuraEnabled(cacheable=true)
  public static List<CustomSettingWrapper> getCustomSettingPermissions(
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
        SetupEntityType = 'CustomEntityDefinition'
        AND ParentId IN :unifiedPermissionSetIds
    ];

    Set<Id> setupEntityIds = new Set<Id>();
    for (SetupEntityAccess sea : setupEntityAccesses) {
      setupEntityIds.add(sea.SetupEntityId);
    }

    List<CustomSettingWrapper> customSettingWrappers = new List<CustomSettingWrapper>();
    for (EntityDefinition cs : [
      SELECT DurableId, QualifiedApiName, label
      FROM EntityDefinition
      WHERE DurableId IN :setupEntityIds AND QualifiedApiName LIKE '%__c'
    ]) {
      customSettingWrappers.add(
        new CustomSettingWrapper(cs.DurableId, cs.QualifiedApiName, cs.label)
      );
    }

    return customSettingWrappers;
  }

  public class CustomSettingWrapper {
    @AuraEnabled
    public Id settingId { get; set; }
    @AuraEnabled
    public String settingName { get; set; }
    @AuraEnabled
    public String settingLabel { get; set; }

    public CustomSettingWrapper(
      Id settingId,
      String settingName,
      String settingLabel
    ) {
      this.settingId = settingId;
      this.settingName = settingName;
      this.settingLabel = settingLabel;
    }
  }
}
