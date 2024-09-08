import { LightningElement } from "lwc";

export default class FilterPanel extends LightningElement {
  handleClick() {}

  options = [{ value: "value", label: "label" }];

  get labels() {
    return { permisionSet: "Permission set", profile: "Profile" };
  }
}
