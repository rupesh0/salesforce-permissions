import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getCustomSettingPermissions from "@salesforce/apex/CustomSettingController.getCustomSettingPermissions";

export default class CustomSettings extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  customSettings = [];
  customSettingsResult;

  @wire(getCustomSettingPermissions, {
    permissionSetIds: "$permissionSetIds",
    profileIds: "$profileIds"
  })
  getCustomSettingPermissionsCallback(result) {
    this.customSettingsResult = result;
    console.log("Assigned Custom Settings Permissions Data:", result);
    const { error, data } = result;
    if (error || data) {
      if (error) {
        console.error(
          "Error fetching assigned custom settings permissions:",
          error
        );
      } else if (data) {
        this.customSettings = data;
      }
      refreshApex(this.customSettingsResult);
    }
  }

  get columns() {
    return [
      { label: "Custom Setting Name", fieldName: "settingName" },
      { label: "Label", fieldName: "settingLabel" }
    ];
  }
}
