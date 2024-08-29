public with sharing class PermissionRequest {
  @AuraEnabled
  public List<Id> profileIds { get; set; }

  @AuraEnabled
  public List<Id> permissionSetIds { get; set; }

  @AuraEnabled
  public List<String> objectApiNames { get; set; }
}
