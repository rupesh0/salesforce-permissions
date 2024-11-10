import getFieldPermissions from "@salesforce/apex/PermissionsController.getFieldPermissions";
import getObjectPermissions from "@salesforce/apex/PermissionsController.getObjectPermissions";
import getObjectInfos from "@salesforce/apex/PermissionsController.getObjectInfos";
import getFieldInfos from "@salesforce/apex/PermissionsController.getFieldInfos";

export async function loadPermissions(filters, objInfo) {
  const loadObjP = Promise.withResolvers();
  const loadFieldP = Promise.withResolvers();

  loadFieldPermissions(filters, objInfo, loadFieldP);
  loadObjectPermissions(filters, objInfo, loadObjP);

  const result = await Promise.all([loadObjP.promise, loadFieldP.promise]);
  return result;
}

function loadFieldPermissions(filters, objInfo, loadFieldP) {
  let promises = [];
  for (let i = 0; i < objInfo.length; i += 400) {
    promises.push(
      getFieldPermissions({
        request: {
          profileIds: filters.profileIds,
          permissionSetIds: filters.permissionSetIds,
          objectApiNames: objInfo.slice(i, i + 400).map((info) => info.apiName)
        }
      })
    );
  }

  Promise.all(promises)
    .then((results) => {
      let allFields = {};
      results.forEach((fields) => {
        allFields = { ...allFields, ...fields };
      });
      loadFieldP.resolve(allFields);
    })
    .catch((error) => {
      loadFieldP.reject(error);
    });
}

function loadObjectPermissions(filters, objInfo, loadObjP) {
  let promises = [];
  for (let i = 0; i < objInfo.length; i += 500) {
    promises.push(
      getObjectPermissions({
        request: {
          profileIds: filters.profileIds,
          permissionSetIds: filters.permissionSetIds,
          objectApiNames: objInfo.slice(i, i + 500).map((info) => info.apiName)
        }
      })
    );
  }

  Promise.all(promises)
    .then((results) => {
      let allObjs = {};
      results.forEach((objs) => {
        allObjs = { ...allObjs, ...objs };
      });
      loadObjP.resolve(allObjs);
    })
    .catch((error) => {
      loadObjP.reject(error);
    });
}

export async function loadObjectInfo() {
  const info = await getObjectInfos();
  return info;
}

export async function loadFields(objInfo) {
  let promises = [];
  for (let i = 0; i < objInfo.length; i += 400) {
    promises.push(
      getFieldInfos({
        objectApiNames: objInfo.slice(i, i + 400).map((info) => info.apiName)
      })
    );
  }

  let result = [];
  await Promise.all(promises).then((results) => {
    result = [...results.flat(2)];
  });
  return result;
}
