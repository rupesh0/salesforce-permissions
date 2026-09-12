import { api, LightningElement, wire } from "lwc";
import { reduceErrors } from "c/utils";
import getOrgWideEmailAddressPermissions from "@salesforce/apex/OrgWideEmailAddressAccessController.getOrgWideEmailAddressPermissions";

export default class OrgWideEmailAddressAccess extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];
  @api searchTerm = "";

  records = [];
  error;
  isLoading = false;

  @wire(getOrgWideEmailAddressPermissions, {
    profileIds: "$profileIds",
    permissionSetIds: "$permissionSetIds"
  })
  getOrgWideEmailAddressPermissionsCallback({ error, data }) {
    this.isLoading = false;
    this.dispatchLoading(false);

    if (error) {
      this.error = reduceErrors(error);
      this.records = [];
      this.dispatchSubtitle(["0 Org-Wide Email Addresses"]);
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
        `${filtered} of ${total} Org-Wide Email Addresses`
      ]);
    } else {
      this.dispatchSubtitle([`${total} Org-Wide Email Addresses`]);
    }
  }

  get filteredRecords() {
    if (!this.searchTerm || !this.searchTerm.trim()) {
      return this.records;
    }
    const term = this.searchTerm.toLowerCase();
    return this.records.filter(
      (row) =>
        row.displayName?.toLowerCase().includes(term) ||
        row.address?.toLowerCase().includes(term) ||
        row.purpose?.toLowerCase().includes(term)
    );
  }

  get hasNoRecords() {
    return !this.isLoading && this.filteredRecords.length === 0;
  }

  get columns() {
    return [
      {
        label: "Organization-Wide Email Address Name",
        fieldName: "displayName"
      },
      { label: "Email Address", fieldName: "address" },
      { label: "Purpose", fieldName: "purpose" }
    ];
  }
}
