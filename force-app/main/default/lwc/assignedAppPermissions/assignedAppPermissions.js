import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import Toast from "lightning/toast";
import { reduceErrors } from "c/utils";
import { LABELS } from "./i18n";

import getAssignedAppPermissions from "@salesforce/apex/AssignedAppPermissionsController.getAssignedAppPermissions";

export default class AssignedAppPermissions extends LightningElement {
  @api permissionSetIds = [];
  @api profileIds = [];

  permissionApps = [];
  assignedAppPermissionsResult;

  @wire(getAssignedAppPermissions, {
    permissionSetIds: "$permissionSetIds",
    profileIds: "$profileIds"
  })
  getAssignedAppPermissionsCallback(result) {
    this.assignedAppPermissionsResult = result;
    const { error, data } = result;
    if (error || data) {
      if (error) {
        Toast.show(
          {
            label:
              LABELS.permissions_label_error_on_fetch_assigned_app_permissions,
            message: reduceErrors(error),
            mode: "sticky",
            variant: "error"
          },
          this
        );
      } else if (data) {
        this.permissionApps = JSON.parse(JSON.stringify(data));
      }
      refreshApex(this.assignedAppPermissionsResult);
    }
    console.log("Assigned App Permissions Data:", result);
  }
}
