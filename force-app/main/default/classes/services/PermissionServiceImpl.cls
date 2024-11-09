public with sharing class PermissionServiceImpl implements PermissionService.API {
  public Map<String, PermissionService.FieldPermissionDTO> getFieldPermissions(
    PermissionRequest request
  ) {
    List<FieldPermissions> fps = [
      SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
      FROM FieldPermissions
      WHERE
        (ParentId IN :request.permissionSetIds
        OR Parent.ProfileId IN :request.profileIds)
        AND SobjectType IN :request.objectApiNames
    ];

    Map<String, PermissionService.FieldPermissionDTO> result = new Map<String, PermissionService.FieldPermissionDTO>();
    for (FieldPermissions fp : fps) {
      PermissionService.FieldPermissionDTO dto = result.get(fp.Field);
      if (dto == null) {
        dto = new PermissionService.FieldPermissionDTO(
          fp.Field,
          fp.SobjectType
        );
      }
      dto.isReadable = dto.isReadable || fp.PermissionsRead;
      dto.isEditable = dto.isEditable || fp.PermissionsEdit;

      result.put(fp.Field, dto);
    }
    return result;
  }

  public Map<String, PermissionService.ObjectPermissionDTO> getObjectPermissions(
    PermissionRequest request
  ) {
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

    Map<String, PermissionService.ObjectPermissionDTO> result = new Map<String, PermissionService.ObjectPermissionDTO>();
    for (ObjectPermissions op : ops) {
      PermissionService.ObjectPermissionDTO dto = result.get(op.SobjectType);
      if (dto == null) {
        dto = new PermissionService.ObjectPermissionDTO(op.sObjectType);
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
  }
}
