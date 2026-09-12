import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getStandardInvocableActionPermissions from "@salesforce/apex/StandardInvocableActionAccessController.getStandardInvocableActionPermissions";

export default class StandardInvocableActionAccess extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  standardInvocableActions = [];
  standardInvocableActionsResult;

  @wire(getStandardInvocableActionPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getStandardInvocableActionPermissionsCallback(result) {
    this.standardInvocableActionsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.standardInvocableActions = data;
      } else if (error) {
        console.error(
          "Error retrieving Standard Invocable Action Permissions: ",
          error
        );
      }
      refreshApex(this.standardInvocableActionsResult);
    }
  }

  get columns() {
    return [
      {
        label: "Standard Invocable Action Name",
        fieldName: "actionName"
      },
      { label: "Label", fieldName: "label" }
    ];
  }
}
