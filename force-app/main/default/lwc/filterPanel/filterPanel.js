import { LightningElement, api } from "lwc";

export default class FilterPanel extends LightningElement {
  @api filterValues;

  handlePermissionSetChange(event) {
    event.stopPropagation();
    this.dispatchFilterChangeEvent({
      permissionSetIds: event.detail.selectedValues
    });
  }

  handleProfileChange(event) {
    event.stopPropagation();
    this.dispatchFilterChangeEvent({ profileIds: event.detail.selectedValues });
  }

  dispatchFilterChangeEvent(detail) {
    this.dispatchEvent(
      new CustomEvent("filterchange", { detail, bubbles: true, composed: true })
    );
  }

  handleResetClick() {
    this.dispatchEvent(
      new CustomEvent("reset", { bubbles: true, composed: true })
    );
  }

  handleClearClick() {
    this.dispatchEvent(
      new CustomEvent("clear", { bubbles: true, composed: true })
    );
  }

  handleApplyClick() {
    this.dispatchEvent(
      new CustomEvent("apply", { bubbles: true, composed: true })
    );
  }
}
