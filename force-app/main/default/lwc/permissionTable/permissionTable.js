import { LightningElement, api } from "lwc";
import { LABELS } from "./i18n";

export default class PermissionTable extends LightningElement {
  @api get fieldPermissions() {
    return this._fieldPermissions;
  }
  set fieldPermissions(value) {
    this._fieldPermissions = value.map((v) => JSON.parse(JSON.stringify(v)));
  }

  @api get objectPermissions() {
    return this._objectPermissions;
  }
  set objectPermissions(value) {
    this._objectPermissions = value.map((v) => JSON.parse(JSON.stringify(v)));
  }

  @api
  applySearchFilterOnObject(searchTerm) {
    this.clearSelection();
    this.searchTerm = searchTerm;
  }

  _fieldPermissions = [];
  _objectPermissions = [];
  selectedObject = null;
  searchTerm = "";

  handleObjectChange(event) {
    this.selectedObject = event.target.dataset.id;
  }

  clearSelection() {
    const ele = this.template.querySelector(
      '[data-id="' + this.selectedObject + '"]'
    );
    if (ele) {
      ele.checked = false;
    }
    this.selectedObject = null;
  }

  get labels() {
    return LABELS;
  }

  get objPermissionsToDisplay() {
    if (!this.searchTerm) {
      return this.objectPermissions;
    }

    return this.objectPermissions.filter((op) =>
      op.label.toLocaleLowerCase().includes(this.searchTerm.toLocaleLowerCase())
    );
  }

  get fieldPermissionsToDisplay() {
    if (!this.selectedObject) {
      return [];
    }

    return this.fieldPermissions.filter(
      (field) => field.objectApiName === this.selectedObject
    );
  }
}
