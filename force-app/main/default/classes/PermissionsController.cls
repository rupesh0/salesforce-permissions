public with sharing class PermissionsController {
  @AuraEnabled
  public static Map<String, FieldPermissionDTO> getFieldPermissions(
    PermissionRequest request
  ) {
    try {
      List<FieldPermissions> fps = [
        SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
        FROM FieldPermissions
        WHERE
          (ParentId IN :request.permissionSetIds
          OR Parent.ProfileId IN :request.profileIds)
          AND SobjectType IN :request.objectApiNames
      ];

      Map<String, FieldPermissionDTO> result = new Map<String, FieldPermissionDTO>();
      for (FieldPermissions fp : fps) {
        FieldPermissionDTO dto = result.get(fp.Field);
        if (dto == null) {
          dto = new FieldPermissionDTO(fp.Field, fp.SobjectType);
        }
        dto.isReadable = dto.isReadable || fp.PermissionsRead;
        dto.isEditable = dto.isEditable || fp.PermissionsEdit;

        result.put(fp.Field, dto);
      }
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, ObjectPermissionDTO> getObjectPermissions(
    PermissionRequest request
  ) {
    try {
      List<ObjectPermissions> ops = [
        SELECT
          SobjectType,
          PermissionsRead,
          PermissionsCreate,
          PermissionsEdit,
          PermissionsDelete,
          PermissionsViewAllRecords,
          PermissionsModifyAllRecords
        FROM ObjectPermissions
        WHERE
          (ParentId IN :request.permissionSetIds
          OR Parent.ProfileId IN :request.profileIds)
          AND SobjectType IN :request.objectApiNames
      ];

      Map<String, ObjectPermissionDTO> result = new Map<String, ObjectPermissionDTO>();
      for (ObjectPermissions op : ops) {
        ObjectPermissionDTO dto = result.get(op.SobjectType);
        if (dto == null) {
          dto = new ObjectPermissionDTO(op.sObjectType);
        }
        dto.isReadable = dto.isReadable || op.PermissionsRead;
        dto.isCreateable = dto.isCreateable || op.PermissionsCreate;
        dto.isEditable = dto.isEditable || op.PermissionsEdit;
        dto.isDeletable = dto.isDeletable || op.PermissionsDelete;
        dto.viewAll = dto.viewAll || op.PermissionsViewAllRecords;
        dto.modifyAll = dto.modifyAll || op.PermissionsModifyAllRecords;

        result.put(op.SobjectType, dto);
      }
      return result;
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

  public with sharing class ObjectPermissionDTO {
    @AuraEnabled
    public String apiName;
    @AuraEnabled
    public Boolean isReadable;
    @AuraEnabled
    public Boolean isCreateable;
    @AuraEnabled
    public Boolean isEditable;
    @AuraEnabled
    public Boolean isDeletable;
    @AuraEnabled
    public Boolean viewAll;
    @AuraEnabled
    public Boolean modifyAll;

    public ObjectPermissionDTO(String apiName) {
      this.apiName = apiName;
      this.isReadable = false;
      this.isCreateable = false;
      this.isEditable = false;
      this.isDeletable = false;
      this.viewAll = false;
      this.modifyAll = false;
    }
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

  public with sharing class FieldPermissionDTO {
    @AuraEnabled
    public String apiName;
    @AuraEnabled
    public String field;
    @AuraEnabled
    public String objectApiName;
    @AuraEnabled
    public Boolean isReadable;
    @AuraEnabled
    public Boolean isEditable;

    public FieldPermissionDTO(String field, String objectApiName) {
      this.field = field;
      this.objectApiName = objectApiName;
      this.apiName = field.replace(objectApiName + '.', '');
      this.isReadable = false;
      this.isEditable = false;
    }
  }
}
