public with sharing class PermissionsController {
  private static List<String> fieldApiNamesToExclude = new List<String>{
    'Id',
    'IsDeleted',
    'MasterRecordId',
    'OwnerId',
    'CreatedDate',
    'CreatedById',
    'LastModifiedDate',
    'LastModifiedById',
    'SystemModstamp',
    'LastActivityDate',
    'LastReferencedDate',
    'LastViewedDate'
  };

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
      List<String> fieldsToExclude = new List<String>();
      for (Field_To_Exclude_In_Permissions__mdt record : [
        SELECT Field__c
        FROM Field_To_Exclude_In_Permissions__mdt
      ]) {
        fieldsToExclude.add(record.Field__c);
      }

      for (String objectApiName : objectApiNames) {
        DescribeSObjectResult dsr = objsInOrg.get(objectApiName).getDescribe();

        List<SObjectField> fields = dsr.fields.getMap().values();

        for (SObjectField field : fields) {
          DescribeFieldResult dfr = field.getDescribe();

          String fieldName = objectApiName + '.' + dfr.getName();
          Boolean include =
            !fieldsToExclude.contains(fieldName) &&
            !fieldApiNamesToExclude.contains(dfr.getName());

          if (include) {
            FieldInfoDTO info = new FieldInfoDTO();
            info.apiName = dfr.getName();
            info.label = dfr.getLabel();
            info.objectApiName = objectApiName;
            info.field = fieldName;

            result.add(info);
          }
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
      List<String> objectApiNames = new List<String>();
      for (Standard_Object_To_Show_In_Permissions__mdt record : [
        SELECT Object_API_Name__c
        FROM Standard_Object_To_Show_In_Permissions__mdt
      ]) {
        objectApiNames.add(record.Object_API_Name__c);
      }

      List<ObjectInfoDTO> result = new List<ObjectInfoDTO>();

      Map<String, sObjectType> objsInOrg = schema.getGlobalDescribe();
      for (sObjectType sobjectType : objsInOrg.values()) {
        DescribeSObjectResult dsr = sobjectType.getDescribe();

        Boolean include =
          dsr.isCustom() || objectApiNames.contains(dsr.getName());
        include =
          include &&
          !dsr.isCustomSetting() &&
          !dsr.getName().endsWith('__mdt');

        if (include) {
          ObjectInfoDTO info = new ObjectInfoDTO();
          info.apiName = dsr.getName();
          info.label = dsr.getLabel();

          result.add(info);
        }
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
