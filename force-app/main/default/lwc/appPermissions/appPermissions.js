import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getAppPermissions from "@salesforce/apex/AppPermissionsController.getAppPermissions";

export default class AppPermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  appPermissions = [];
  appPermissionsResult;

  @wire(getAppPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getAppPermissionsCallback(result) {
    this.appPermissionsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.appPermissions = data;
      } else if (error) {
        console.error("Error retrieving App Permissions: ", error);
      }
      refreshApex(this.appPermissionsResult);
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
