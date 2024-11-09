import { LightningElement, wire, api } from "lwc";
import getProfileOptions from "@salesforce/apex/CommonController.getProfileOptions";
import { reduceErrors } from "c/ldsUtils";
import Toast from "lightning/toast";

export default class ProfileCombobox extends LightningElement {
  @api selectedValues;

  options = [];

  @wire(getProfileOptions)
  getPermissionSetOptionsCallback({ error, data }) {
    if (error) {
      this.options = this.selectedValues.map((value) => {
        return { value, label: value };
      });
      const reduceError = reduceErrors(error);
      Toast.show(
        {
          label: "Error in loading Profile combobox options",
          message: reduceError,
          mode: "sticky",
          variant: "error"
        },
        this
      );
    } else if (data) {
      this.options = JSON.parse(JSON.stringify(data));
    }
  }

  get labels() {
    return { profile: "Profile" };
  }
}
