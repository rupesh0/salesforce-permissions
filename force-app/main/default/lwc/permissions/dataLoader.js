import getFieldPermissions from "@salesforce/apex/PermissionsController.getFieldPermissions";
import getObjectPermissions from "@salesforce/apex/PermissionsController.getObjectPermissions";
import getObjectInfos from "@salesforce/apex/PermissionsController.getObjectInfos";
import getFieldInfos from "@salesforce/apex/PermissionsController.getFieldInfos";

export async function loadPermissions(state) {
  const loadObjP = Promise.withResolvers();
  const loadFieldP = Promise.withResolvers();

  loadFieldPermissions(state, loadFieldP);
  loadObjectPermissions(state, loadObjP);

  await Promise.all([loadObjP.promise, loadFieldP.promise]);
}

export async function loadFields(state) {
  let promises = [];
  for (let i = 0; i < state.objInfo.length; i += 400) {
    promises.push(
      getFieldInfos({
        objectApiNames: state.objInfo
          .slice(i, i + 400)
          .map((info) => info.apiName)
      })
    );
  }

  await Promise.all(promises).then((results) => {
    state.fieldInfo = [...results.flat(2)];
  });
}

function loadFieldPermissions(state, loadFieldP) {
  let promises = [];
  for (let i = 0; i < state.objInfo.length; i += 400) {
    promises.push(
      getFieldPermissions({
        request: {
          profileIds: state.filters.profileIds,
          permissionSetIds: state.filters.permissionSetIds,
          objectApiNames: state.objInfo
            .slice(i, i + 400)
            .map((info) => info.apiName)
        }
      })
    );
  }

  Promise.all(promises)
    .then((results) => {
      let a = {};
      results.forEach((d) => {
        a = { ...a, ...d };
      });
      state.fieldPermissions = a;
      loadFieldP.resolve();
    })
    .catch((error) => {
      loadFieldP.reject(error);
    });
}

function loadObjectPermissions(state, loadObjP) {
  let promises = [];
  for (let i = 0; i < state.objInfo.length; i += 500) {
    promises.push(
      getObjectPermissions({
        request: {
          profileIds: state.filters.profileIds,
          permissionSetIds: state.filters.permissionSetIds,
          objectApiNames: state.objInfo
            .slice(i, i + 500)
            .map((info) => info.apiName)
        }
      })
    );
  }

  Promise.all(promises)
    .then((results) => {
      let a = {};
      results.forEach((d) => {
        a = { ...a, ...d };
      });

      state.objPermissions = a;
      loadObjP.resolve();
    })
    .catch((error) => {
      loadObjP.reject(error);
    });
}

export async function loadObjectInfo() {
  const info = await getObjectInfos();
  return info;
}
