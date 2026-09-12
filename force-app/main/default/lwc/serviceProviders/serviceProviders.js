import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getServiceProviderPermissions from "@salesforce/apex/ServiceProvidersController.getServiceProviderPermissions";

export default class ServiceProviders extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  serviceProviders = [];
  serviceProvidersResult;

  @wire(getServiceProviderPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getServiceProviderPermissionsCallback(result) {
    this.serviceProvidersResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.serviceProviders = data;
      } else if (error) {
        console.error("Error retrieving Service Providers: ", error);
      }
      refreshApex(this.serviceProvidersResult);
    }
  }

  get columns() {
    return [
      { label: "Service Provider Name", fieldName: "serviceProviderName" },
      { label: "Start URL", fieldName: "startUrl" }
    ];
  }
}
