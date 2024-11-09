import { LightningElement, api, wire } from "lwc";
import getPermissionSetOptions from "@salesforce/apex/CommonController.getPermissionSetOptions";
import { reduceErrors } from "c/ldsUtils";
import Toast from "lightning/toast";

export default class PermissionSetCombobox extends LightningElement {
  @api selectedValues;

  error = null;
  options = [];

  @wire(getPermissionSetOptions)
  getPermissionSetOptionsCallback({ error, data }) {
    if (error) {
      this.options = this.selectedValues.map((value) => {
        return { value, label: value };
      });
      const reduceError = reduceErrors(error);
      Toast.show(
        {
          label: "Error in loading Permission Set combobox options",
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
    return { permisionSet: "Permission set" };
  }
}
