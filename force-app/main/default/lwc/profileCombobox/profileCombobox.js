import { LightningElement, wire, api } from "lwc";
import getProfileOptions from "@salesforce/apex/CommonController.getProfileOptions";
import { reduceErrors } from "c/ldsUtils";

export default class ProfileCombobox extends LightningElement {
  @api selectedValues;

  error = null;
  options = [];
  showCombobox = false;

  @wire(getProfileOptions)
  getPermissionSetOptionsCallback({ error, data }) {
    if (error) {
      this.error = reduceErrors(error);
    } else if (data) {
      this.options = JSON.parse(JSON.stringify(data));
      this.showCombobox = true;
    }
  }

  get labels() {
    return { profile: "Profile" };
  }
}
