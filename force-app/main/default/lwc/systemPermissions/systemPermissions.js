import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getSystemPermissions from "@salesforce/apex/SystemPermissionsController.getSystemPermissions";

export default class SystemPermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  systemPermissions = [];
  systemPermissionsResult;

  @wire(getSystemPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getSystemPermissionsCallback(result) {
    this.systemPermissionsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.systemPermissions = data;
      } else if (error) {
        console.error("Error retrieving System Permissions: ", error);
      }
      refreshApex(this.systemPermissionsResult);
    }
  }

  get columns() {
    return [
      { label: "Label", fieldName: "label" },
      { label: "API Name", fieldName: "apiName" },
      { label: "Description", fieldName: "description" }
    ];
  }
}
