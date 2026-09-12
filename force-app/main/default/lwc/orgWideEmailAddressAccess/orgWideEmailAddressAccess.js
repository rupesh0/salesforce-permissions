import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getOrgWideEmailAddressPermissions from "@salesforce/apex/OrgWideEmailAddressAccessController.getOrgWideEmailAddressPermissions";

export default class OrgWideEmailAddressAccess extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  orgWideEmailPermissions = [];
  orgWideEmailPermissionsResult;

  @wire(getOrgWideEmailAddressPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getOrgWideEmailAddressPermissionsCallback(result) {
    this.orgWideEmailPermissionsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.orgWideEmailPermissions = data;
      } else if (error) {
        console.error(
          "Error retrieving Org-Wide Email Address Permissions: ",
          error
        );
      }
      refreshApex(this.orgWideEmailPermissionsResult);
    }
  }

  get columns() {
    return [
      {
        label: "Organization-Wide Email Address Name",
        fieldName: "displayName"
      },
      { label: "Email Address", fieldName: "address" },
      { label: "Purpose", fieldName: "purpose" }
    ];
  }
}
