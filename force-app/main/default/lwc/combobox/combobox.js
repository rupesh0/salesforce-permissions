import { LightningElement, api } from "lwc";

export default class Combobox extends LightningElement {
  @api label = "Permission set";

  @api placeHolder = "Search...";

  get labels() {
    return {
      iconAltText: "Search"
    };
  }
}
