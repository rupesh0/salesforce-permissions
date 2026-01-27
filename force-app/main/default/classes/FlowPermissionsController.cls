public with sharing class FlowPermissionsController {
  @AuraEnabled(cacheable=true)
  public static List<FlowPermissionWrapper> getFlowPermissions(
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
        SetupEntityType = 'FlowDefinition'
        AND ParentId IN :unifiedPermissionSetIds
    ];

    Set<Id> setupEntityIds = new Set<Id>();
    for (SetupEntityAccess sea : setupEntityAccesses) {
      setupEntityIds.add(sea.SetupEntityId);
    }

    List<FlowPermissionWrapper> flowPermissions = new List<FlowPermissionWrapper>();
    for (FlowDefinitionView flowDef : [
      SELECT DurableId, Label, ProcessType
      FROM FlowDefinitionView
      WHERE DurableId IN :setupEntityIds
    ]) {
      flowPermissions.add(
        new FlowPermissionWrapper(flowDef.DurableId, flowDef.Label)
      );
    }

    return flowPermissions;
  }

  public with sharing class FlowPermissionWrapper {
    @AuraEnabled
    public String flowId { get; set; }
    @AuraEnabled
    public String flowName { get; set; }

    public FlowPermissionWrapper(String flowId, String flowName) {
      this.flowId = flowId;
      this.flowName = flowName;
    }
  }
}
