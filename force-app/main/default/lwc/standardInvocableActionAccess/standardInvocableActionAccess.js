import { api, LightningElement, wire } from "lwc";
import { reduceErrors } from "c/utils";
import getStandardInvocableActionPermissions from "@salesforce/apex/StandardInvocableActionAccessController.getStandardInvocableActionPermissions";

export default class StandardInvocableActionAccess extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];
  @api searchTerm = "";

  records = [];
  error;
  isLoading = false;

  @wire(getStandardInvocableActionPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getStandardInvocableActionPermissionsCallback({ error, data }) {
    this.isLoading = false;
    this.dispatchLoading(false);

    if (error) {
      this.error = reduceErrors(error);
      this.records = [];
      this.dispatchSubtitle(["0 Standard Invocable Actions"]);
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
      this.dispatchSubtitle([
        `${filtered} of ${total} Standard Invocable Actions`
      ]);
    } else {
      this.dispatchSubtitle([`${total} Standard Invocable Actions`]);
    }
  }

  get filteredRecords() {
    if (!this.searchTerm || !this.searchTerm.trim()) {
      return this.records;
    }
    const term = this.searchTerm.toLowerCase();
    return this.records.filter(
      (row) =>
        row.actionName?.toLowerCase().includes(term) ||
        row.label?.toLowerCase().includes(term)
    );
  }

  get hasNoRecords() {
    return !this.isLoading && this.filteredRecords.length === 0;
  }

  get columns() {
    return [
      {
        label: "Standard Invocable Action Name",
        fieldName: "actionName"
      },
      { label: "Label", fieldName: "label" }
    ];
  }
}
