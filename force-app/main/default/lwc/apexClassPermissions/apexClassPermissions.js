import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getApexClassPermissions from "@salesforce/apex/ApexClassPermissionsController.getApexClassPermissions";

export default class ApexClassPermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  apexClassPermissions = [];
  getApexClassPermissionsResult;

  @wire(getApexClassPermissions, {
    permissionSetIds: "$permissionSetIds",
    profileIds: "$profileIds"
  })
  getApexClassPermissionsCallback(result) {
    this.getApexClassPermissionsResult = result;
    const { error, data } = result;
    if (error || data) {
      if (error) {
        console.error("Error fetching apex class permissions:", error);
      } else if (data) {
        this.apexClassPermissions = data;
      }
      refreshApex(this.getApexClassPermissionsResult);
    }
  }

  get columns() {
    return [
      { label: "Namespace", fieldName: "namespace" },
      { label: "Apex Class Name", fieldName: "className" }
    ];
  }
}
