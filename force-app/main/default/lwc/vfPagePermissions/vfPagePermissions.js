import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getVFPagePermissions from "@salesforce/apex/VFPagePermissionsController.getVFPagePermissions";

export default class VfPagePermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  vfPagePermissions = [];
  vfPagePermissionsResult;

  @wire(getVFPagePermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getVFPagePermissionsCallback(result) {
    this.vfPagePermissionsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.vfPagePermissions = data;
      } else if (error) {
        console.error("Error retrieving VF Page Permissions:", error);
      }
      refreshApex(this.vfPagePermissionsResult);
    }
  }

  get columns() {
    return [
      { label: "Namespace Prefix", fieldName: "namespacePrefix", type: "text" },
      { label: "VF Page Name", fieldName: "vfPageName", type: "text" }
    ];
  }
}
