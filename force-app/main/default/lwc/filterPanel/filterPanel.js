import { LightningElement, api } from "lwc";
import {
  ApplyEvent,
  ClearEvent,
  ResetEvent,
  FilterChangeEvent
} from "./events";

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
    this.dispatchEvent(new FilterChangeEvent(detail));
  }

  handleResetClick() {
    this.dispatchEvent(new ResetEvent());
  }

  handleClearClick() {
    this.dispatchEvent(new ClearEvent());
  }

  handleApplyClick() {
    this.dispatchEvent(new ApplyEvent());
  }
}
