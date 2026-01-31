import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getCustomMetadataTypePermissions from "@salesforce/apex/CustomMetadataTypeController.getCustomMetadataTypePermissions";

export default class CustomMetadataTypes extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  customMetadataTypes = [];
  customMetadataTypesResult;

  @wire(getCustomMetadataTypePermissions, {
    permissionSetIds: "$permissionSetIds",
    profileIds: "$profileIds"
  })
  getCustomMetadataTypePermissionsCallback(result) {
    this.customMetadataTypesResult = result;
    const { error, data } = result;
    if (error || data) {
      if (error) {
        console.error(
          "Error fetching assigned custom metadata types permissions:",
          error
        );
      } else if (data) {
        this.customMetadataTypes = data;
      }
      refreshApex(this.customMetadataTypesResult);
    }
  }

  get columns() {
    return [
      { label: "Custom Metadata Type", fieldName: "metadataName" },
      { label: "Label", fieldName: "metadataLabel" }
    ];
  }
}
