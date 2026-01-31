public with sharing class CustomMetadataTypeController {
  @AuraEnabled(cacheable=true)
  public static List<CustomMetadataTypeWrapper> getCustomMetadataTypePermissions(
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

    List<CustomMetadataTypeWrapper> customMetadataTypeWrappers = new List<CustomMetadataTypeWrapper>();
    for (EntityDefinition cs : [
      SELECT DurableId, QualifiedApiName, label
      FROM EntityDefinition
      WHERE DurableId IN :setupEntityIds AND QualifiedApiName LIKE '%__mdt'
    ]) {
      customMetadataTypeWrappers.add(
        new CustomMetadataTypeWrapper(
          cs.DurableId,
          cs.QualifiedApiName,
          cs.label
        )
      );
    }

    return customMetadataTypeWrappers;
  }

  public class CustomMetadataTypeWrapper {
    @AuraEnabled
    public Id metaDataId { get; set; }
    @AuraEnabled
    public String metadataName { get; set; }
    @AuraEnabled
    public String metadataLabel { get; set; }
    public CustomMetadataTypeWrapper(
      Id metaDataId,
      String metadataName,
      String metadataLabel
    ) {
      this.metaDataId = metaDataId;
      this.metadataName = metadataName;
      this.metadataLabel = metadataLabel;
    }
  }
}
