import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getAssignedConnectedAppPermissions from "@salesforce/apex/AssignedConnectedAppController.getAssignedConnectedAppPermissions";

export default class AssignedConnectedApp extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  assignedConnectedApps = [];
  assignedConnectedAppsResult;

  @wire(getAssignedConnectedAppPermissions, {
    permissionSetIds: "$permissionSetIds",
    profileIds: "$profileIds"
  })
  getAssignedConnectedAppPermissionsCallback(result) {
    this.assignedConnectedAppsResult = result;
    console.log("Assigned Connected App Permissions Data:", result);
    const { error, data } = result;
    if (error || data) {
      if (error) {
        console.error(
          "Error fetching assigned connected app permissions:",
          error
        );
      } else if (data) {
        this.assignedConnectedApps = data;
      }
      refreshApex(this.assignedConnectedAppsResult);
    }
  }

  get columns() {
    return [{ label: "Connected App Name", fieldName: "label" }];
  }
}
