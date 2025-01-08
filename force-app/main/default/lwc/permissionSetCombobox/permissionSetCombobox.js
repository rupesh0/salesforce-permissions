import { LightningElement, api, wire } from "lwc";
import getPermissionSetOptions from "@salesforce/apex/CommonController.getPermissionSetOptions";
import { reduceErrors } from "c/ldsUtils";
import Toast from "lightning/toast";
import { LABELS } from "./i18n";

export default class PermissionSetCombobox extends LightningElement {
  @api selectedValues;

  error = null;
  options = [];

  @wire(getPermissionSetOptions)
  getPermissionSetOptionsCallback({ error, data }) {
    if (error) {
      const reduceError = reduceErrors(error);
      Toast.show(
        {
          label:
            LABELS.permissions_label_error_on_fetch_permission_set_combobox_options,
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
    return LABELS;
  }
}
