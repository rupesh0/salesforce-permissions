public with sharing class StandardInvocableActionAccessController {
  @AuraEnabled(cacheable=true)
  public static List<StandardInvocableActionWrapper> getStandardInvocableActionPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<StandardInvocableActionWrapper> standardInvocableActions = new List<StandardInvocableActionWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );

      List<SetupEntityAccess> setupEntityAccesses = [
        SELECT SetupEntityId
        FROM SetupEntityAccess
        WHERE
          SetupEntityType = 'InvocableAction'
          AND ParentId IN :unifiedPermissionSetIds
      ];

      Set<Id> setupEntityIds = new Set<Id>();
      for (SetupEntityAccess sea : setupEntityAccesses) {
        setupEntityIds.add(sea.SetupEntityId);
      }

      for (EntityDefinition ed : [
        SELECT DurableId, QualifiedApiName, Label
        FROM EntityDefinition
        WHERE DurableId IN :setupEntityIds
      ]) {
        standardInvocableActions.add(
          new StandardInvocableActionWrapper(
            ed.DurableId,
            ed.QualifiedApiName,
            ed.Label
          )
        );
      }

      return standardInvocableActions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class StandardInvocableActionWrapper {
    @AuraEnabled
    public String actionId { get; set; }
    @AuraEnabled
    public String actionName { get; set; }
    @AuraEnabled
    public String label { get; set; }

    public StandardInvocableActionWrapper(
      String actionId,
      String actionName,
      String label
    ) {
      this.actionId = actionId;
      this.actionName = actionName;
      this.label = label;
    }
  }
}
