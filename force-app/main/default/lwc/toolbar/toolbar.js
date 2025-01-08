import { api, LightningElement } from "lwc";
import { SearchEvent } from "./events";
import { MIN_SEARCH_LENGTH } from "./constants";
import { LABELS } from "./i18n";
import { stringFormat } from "c/utils";

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
    return LABELS;
  }

  get subTitles() {
    return [ 
      stringFormat(LABELS.common_label_x_objects, this.objectCount),
      stringFormat(LABELS.common_label_x_fields, this.fieldCount)
     ];
  }

  get minInputLength() {
    return MIN_SEARCH_LENGTH;
  }
}
