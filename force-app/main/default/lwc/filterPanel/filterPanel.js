import { LightningElement } from "lwc";

export default class FilterPanel extends LightningElement {
  handleClick() {}

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

  get labels() {
    return { permisionSet: "Permission set", profile: "Profile" };
  }
}
