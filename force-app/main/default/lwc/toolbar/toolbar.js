import { api, LightningElement } from "lwc";
import { SearchEvent } from "./events";
import { MIN_SEARCH_LENGTH } from "./constants";
import { LABELS } from "./i18n";
import { stringFormat } from "c/utils";

export default class Toolbar extends LightningElement {
  @api title;
  @api subTitles;
  @api objectCount = 0;
  @api fieldCount = 0;
  @api filterValues;
  @api searchPlaceholder;

  isFilterPanelOpen = false;

  handleInputChange() {
    const input = this.template.querySelector("lightning-input");
    const isValid =
      input &&
      (typeof input.reportValidity !== "function" ||
        input.reportValidity() !== false);
    if (isValid) {
      this.dispatchEvent(new SearchEvent(input.value));
    }
  }

  handleFilterButtonClick() {
    this.isFilterPanelOpen = !this.isFilterPanelOpen;
  }

  handleApply() {
    this.isFilterPanelOpen = false;
    this.dispatchEvent(new CustomEvent("apply"));
  }

  handleClear() {
    this.isFilterPanelOpen = false;
    this.dispatchEvent(new CustomEvent("clear"));
  }

  handleReset() {
    this.isFilterPanelOpen = false;
    this.dispatchEvent(new CustomEvent("reset"));
  }

  handleFilterChange(event) {
    this.dispatchEvent(
      new CustomEvent("filterchange", {
        detail: event.detail
      })
    );
  }

  get pageTitle() {
    return this.title || this.labels.common_label_permissions;
  }

  get labels() {
    return LABELS;
  }

  get subTitleList() {
    if (Array.isArray(this.subTitles) && this.subTitles.length > 0) {
      return this.subTitles;
    }
    if (typeof this.subTitles === "string" && this.subTitles) {
      return [this.subTitles];
    }
    if (this.objectCount || this.fieldCount) {
      return [
        stringFormat(LABELS.common_label_x_objects, this.objectCount),
        stringFormat(LABELS.common_label_x_fields, this.fieldCount)
      ];
    }
    return [];
  }

  get searchPlaceholderText() {
    return (
      this.searchPlaceholder || this.labels.common_label_search_object_holder
    );
  }

  get minInputLength() {
    return MIN_SEARCH_LENGTH;
  }
}
