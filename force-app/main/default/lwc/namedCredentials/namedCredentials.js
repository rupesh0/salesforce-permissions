import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getNamedCredentialPermissions from "@salesforce/apex/NamedCredentialController.getNamedCredentialPermissions";

export default class NamedCredentials extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];

  namedCredentials = [];
  namedCredentialsResult;

  @wire(getNamedCredentialPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getNamedCredentialsCallback(result) {
    this.namedCredentialsResult = result;
    const { data, error } = result;
    if (data || error) {
      if (data) {
        this.namedCredentials = data;
      } else if (error) {
        console.error("Error retrieving Named Credentials: ", error);
      }
      refreshApex(this.namedCredentialsResult);
    }
  }

  get columns() {
    return [
      { label: "Named Credential Name", fieldName: "namedCredentialName" }
    ];
  }
}
