import { LightningElement, api } from "lwc";

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

  @api get selectedObject() {
    return this._selectedObject;
  }
  set selectedObject(value) {
    this.clearSelection();
    this._selectedObject = value;
  }

  _fieldPermissions = [];
  _objectPermissions = [];
  _selectedObject = null;

  handleObjectChange(event) {
    this._selectedObject = event.target.dataset.id;
  }

  clearSelection() {
    const ele = this.template.querySelector(
      '[data-id="' + this.selectedObject + '"]'
    );
    if (ele) {
      ele.checked = false;
    }
  }
  get labels() {
    return {
      label: "Label",
      apiName: "API Name",
      read: "Read",
      create: "Create",
      edit: "Edit",
      delete: "Delete",
      viewAll: "View All",
      modifyAll: "Modify All"
    };
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
