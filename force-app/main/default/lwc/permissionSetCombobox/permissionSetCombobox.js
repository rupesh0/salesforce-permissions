import { LightningElement, api, wire } from "lwc";
import getPermissionSetOptions from "@salesforce/apex/CommonController.getPermissionSetOptions";
import { reduceErrors } from "c/ldsUtils";

export default class PermissionSetCombobox extends LightningElement {
  @api selectedValues;

  error = null;
  options = [];
  showCombobox = false;

  @wire(getPermissionSetOptions)
  getPermissionSetOptionsCallback({ error, data }) {
    if (error) {
      this.error = reduceErrors(error);
    } else if (data) {
      this.options = JSON.parse(JSON.stringify(data));
      this.showCombobox = true;
    }
  }

  get labels() {
    return { permisionSet: "Permission set" };
  }
}
