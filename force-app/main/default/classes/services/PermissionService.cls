public with sharing class PermissionService {
  public static final Dependency impl = new Dependency(
    PermissionServiceImpl.class
  );

  private static API service() {
    return (API) impl.newInstance();
  }

  public interface API {
    Map<String, FieldPermissionDTO> getFieldPermissions(
      PermissionRequest request
    );
    Map<String, ObjectPermissionDTO> getObjectPermissions(
      PermissionRequest request
    );
  }

  public static Map<String, FieldPermissionDTO> getFieldPermissions(
    PermissionRequest request
  ) {
    return service().getFieldPermissions(request);
  }

  public static Map<String, ObjectPermissionDTO> getObjectPermissions(
    PermissionRequest request
  ) {
    return service().getObjectPermissions(request);
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
