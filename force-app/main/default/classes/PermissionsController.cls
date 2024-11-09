public with sharing class PermissionsController {
  @AuraEnabled
  public static Map<String, PermissionService.FieldPermissionDTO> getFieldPermissions(
    PermissionRequest request
  ) {
    try {
      return PermissionService.getFieldPermissions(request);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, PermissionService.ObjectPermissionDTO> getObjectPermissions(
    PermissionRequest request
  ) {
    try {
      return PermissionService.getObjectPermissions(request);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<FieldInfoDTO> getFieldInfos(List<String> objectApiNames) {
    try {
      List<FieldInfoDTO> result = new List<FieldInfoDTO>();

      Map<String, sObjectType> objsInOrg = schema.getGlobalDescribe();

      for (String objectApiName : objectApiNames) {
        DescribeSObjectResult dsr = objsInOrg.get(objectApiName).getDescribe();

        List<SObjectField> fields = dsr.fields.getMap().values();

        for (SObjectField field : fields) {
          DescribeFieldResult dfr = field.getDescribe();

          FieldInfoDTO info = new FieldInfoDTO();
          info.apiName = dfr.getName();
          info.label = dfr.getLabel();
          info.objectApiName = objectApiName;
          info.field = objectApiName + '.' + info.apiName;

          result.add(info);
        }
      }
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<ObjectInfoDTO> getObjectInfos() {
    try {
      List<ObjectInfoDTO> result = new List<ObjectInfoDTO>();

      Map<String, sObjectType> objsInOrg = schema.getGlobalDescribe();
      for (sObjectType sobjectType : objsInOrg.values()) {
        DescribeSObjectResult dsr = sobjectType.getDescribe();

        ObjectInfoDTO info = new ObjectInfoDTO();
        info.apiName = dsr.getName();
        info.label = dsr.getLabel();

        result.add(info);
      }
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public with sharing class ObjectInfoDTO {
    @AuraEnabled
    public String apiName;

    @AuraEnabled
    public String label;
  }

  public with sharing class FieldInfoDTO {
    @AuraEnabled
    public String apiName;

    @AuraEnabled
    public String label;

    @AuraEnabled
    public String field;

    @AuraEnabled
    public String objectApiName;
  }
}
