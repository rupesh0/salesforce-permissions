import { LightningElement, api } from "lwc";

export default class FilterPanel extends LightningElement {
  @api filterValues;

  options = [{ value: "value", label: "label" }];

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
