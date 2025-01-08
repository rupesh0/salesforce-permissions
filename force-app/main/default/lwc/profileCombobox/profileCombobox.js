import { LightningElement, wire, api } from "lwc";
import getProfileOptions from "@salesforce/apex/CommonController.getProfileOptions";
import { reduceErrors } from "c/utils";
import Toast from "lightning/toast";
import { LABELS } from "./i18n";

export default class ProfileCombobox extends LightningElement {
  @api selectedValues;

  options = [];

  @wire(getProfileOptions)
  getPermissionSetOptionsCallback({ error, data }) {
    if (error) {
      const reduceError = reduceErrors(error);
      Toast.show(
        {
          label:
            LABELS.permissions_label_error_on_fetch_profile_combobox_options,
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
