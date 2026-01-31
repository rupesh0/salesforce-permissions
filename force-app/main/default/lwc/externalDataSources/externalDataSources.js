import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getExternalDataSourcePermissions from "@salesforce/apex/ExternalDataSourceController.getExternalDataSourcePermissions";

export default class ExternalDataSources extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  externalDataSources = [];
  externalDataSourcesResult;

  @wire(getExternalDataSourcePermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getExternalDataSourcePermissionsCallback(result) {
    this.externalDataSourcesResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.externalDataSources = data;
      } else if (error) {
        console.error("Error retrieving External Data Sources: ", error);
      }
      refreshApex(this.externalDataSourcesResult);
    }
  }

  get columns() {
    return [{ label: "External Data Source Name", fieldName: "label" }];
  }
}
