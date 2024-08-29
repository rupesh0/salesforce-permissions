export function processData(state) {
  state.objPermissions = state.objInfo.map((obj) => {
    const existing = state.objPermissions[obj.apiName];
    if (existing) {
      return { ...obj, ...existing };
    }
    return {
      ...obj,
      isReadable: false,
      isCreateable: false,
      isEditable: false,
      isDeletable: false,
      viewAll: false,
      modifyAll: false
    };
  });

  state.fieldPermissions = state.fieldInfo.map((fieldInfo) => {
    const existing = state.fieldPermissions[fieldInfo.field];
    if (existing) {
      return { ...fieldInfo, ...existing };
    }
    return {
      ...fieldInfo,
      isReadable: false,
      isEditable: false
    };
  });
}
