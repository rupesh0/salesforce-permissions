import { api, LightningElement, wire } from "lwc";
import { reduceErrors } from "c/utils";
import getCustomSettingPermissions from "@salesforce/apex/CustomSettingController.getCustomSettingPermissions";

export default class CustomSettings extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];
  @api searchTerm = "";

  records = [];
  error;
  isLoading = false;

  @wire(getCustomSettingPermissions, {
    permissionSetIds: "$permissionSetIds",
    profileIds: "$profileIds"
  })
  getCustomSettingPermissionsCallback({ error, data }) {
    this.isLoading = false;
    this.dispatchLoading(false);

    if (error) {
      this.error = reduceErrors(error);
      this.records = [];
      this.dispatchSubtitle(["0 Custom Settings"]);
      this.dispatchEvent(
        new CustomEvent("error", {
          detail: { error: this.error },
          bubbles: true,
          composed: true
        })
      );
    } else if (data) {
      this.error = undefined;
      this.records = data;
      this.updateSubtitle();
    }
  }

  renderedCallback() {
    this.updateSubtitle();
  }

  dispatchLoading(isLoading) {
    this.dispatchEvent(
      new CustomEvent("loadingchange", {
        detail: { isLoading },
        bubbles: true,
        composed: true
      })
    );
  }

  dispatchSubtitle(subTitles) {
    this.dispatchEvent(
      new CustomEvent("subtitlechange", {
        detail: { subTitles },
        bubbles: true,
        composed: true
      })
    );
  }

  updateSubtitle() {
    const total = this.records.length;
    const filtered = this.filteredRecords.length;
    if (this.searchTerm && this.searchTerm.trim().length > 0) {
      this.dispatchSubtitle([`${filtered} of ${total} Custom Settings`]);
    } else {
      this.dispatchSubtitle([`${total} Custom Settings`]);
    }
  }

  get filteredRecords() {
    if (!this.searchTerm || !this.searchTerm.trim()) {
      return this.records;
    }
    const term = this.searchTerm.toLowerCase();
    return this.records.filter(
      (row) =>
        row.settingName?.toLowerCase().includes(term) ||
        row.settingLabel?.toLowerCase().includes(term)
    );
  }

  get hasNoRecords() {
    return !this.isLoading && this.filteredRecords.length === 0;
  }

  get columns() {
    return [
      { label: "Custom Setting Name", fieldName: "settingName" },
      { label: "Label", fieldName: "settingLabel" }
    ];
  }
}
