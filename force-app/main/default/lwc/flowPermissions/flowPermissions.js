import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getFlowPermissions from "@salesforce/apex/FlowPermissionsController.getFlowPermissions";

export default class FlowPermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  flowPermissionsResult;
  flowPermissions;

  @wire(getFlowPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getFlowPermissionsCallback(result) {
    this.flowPermissionsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.flowPermissions = data;
      } else if (error) {
        console.error("Error retrieving Flow Permissions: ", error);
      }
      refreshApex(this.flowPermissionsResult);
    }
  }

  get columns() {
    return [{ label: "Flow Name", fieldName: "flowName" }];
  }
}
