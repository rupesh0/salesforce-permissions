import { LightningElement, api } from "lwc";
import { LABELS } from "./i18n";
import { DEFAULT_LEFT_WIDTH, GRID_HEIGHT, STORAGE_KEY } from "./constants";

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
  leftWidth;
  minPercent = 10;
  maxPercent = 90;

  handleObjectChange(event) {
    this.selectedObject = event.target.dataset.id;
  }

  preventDefaultCheck(event) {
    event.preventDefault();
  }

  connectedCallback() {
    try {
      const savedWidth = window.localStorage.getItem(STORAGE_KEY);
      this.leftWidth = savedWidth ? Number(savedWidth) : DEFAULT_LEFT_WIDTH;
    } catch (e) {
      this.leftWidth = DEFAULT_LEFT_WIDTH;
    }
  }

  onPointerDownHandler() {
    const container = this.template.querySelector(".container");
    const rect = container.getBoundingClientRect();

    const move = (ev) => {
      const x = ev.clientX - rect.left;
      let newWidth = (x / rect.width) * 100;

      if (newWidth < this.minPercent) {
        newWidth = this.minPercent;
      }
      if (newWidth > this.maxPercent) {
        newWidth = this.maxPercent;
      }

      this.leftWidth = newWidth;
      window.localStorage.setItem(STORAGE_KEY, this.leftWidth);
    };

    const up = () => {
      window.removeEventListener("pointermove", move);
      window.removeEventListener("pointerup", up);
    };

    window.addEventListener("pointermove", move);
    window.addEventListener("pointerup", up);
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

  get leftStyle() {
    return `flex: 0 0 ${this.leftWidth - 0.5}%; height: ${GRID_HEIGHT}px`;
  }
  get rightStyle() {
    return `flex: 0 0 ${100 - this.leftWidth}%; height: ${GRID_HEIGHT}px`;
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
