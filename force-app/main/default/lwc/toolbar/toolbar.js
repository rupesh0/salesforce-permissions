import { api, LightningElement } from "lwc";
import { SearchEvent } from "./events";
import { MIN_SEARCH_LENGTH } from "./constants";

export default class Toolbar extends LightningElement {
  @api objectCount = 0;
  @api fieldCount = 0;
  @api filterValues;

  isFilterPanelOpen = false;

  handleInputChange() {
    const input = this.template.querySelector("lightning-input");
    if (input.reportValidity()) {
      this.dispatchEvent(new SearchEvent(input.value));
    }
  }

  handleFilterButtonClick() {
    this.isFilterPanelOpen = !this.isFilterPanelOpen;
  }

  get labels() {
    return {
      title: "Permissions",
      inputPlaceHolder: "Enter Object Name",
      filter: "Filter"
    };
  }

  get subTitles() {
    return [`${this.objectCount} Objects`, `${this.fieldCount} Fields`];
  }

  get minInputLength() {
    return MIN_SEARCH_LENGTH;
  }
}
