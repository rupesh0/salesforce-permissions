import { api, LightningElement, track } from "lwc";
import Toast from "lightning/toast";
import { loadPermissions, loadObjectInfo, loadFields } from "./dataLoader.js";
import { reduceErrors } from "c/utils";
import { processData } from "./dataProcessor.js";
import { makeFilters } from "./filters.js";
import { LABELS } from "./i18n.js";

export default class Permissions extends LightningElement {
  @api
  get filters() {
    return this.filterController.currentFilters;
  }
  set filters(value) {
    this.filterController.setDefaults(value);
  }

  @track state = {
    objInfo: [],
    fieldInfo: [],
    objPermissions: [],
    fieldPermissions: []
  };

  localStorageKey = "myPermissions";
  _filterController;
  error;
  showTable;
  isLoading = true;
  objectCount = 0;
  fieldCount = 0;

  async connectedCallback() {
    try {
      this.isLoading = true;
      this.filterController.loadFromLocalStorage();
      this.state.objInfo = await loadObjectInfo();
      const promises = [loadFields(this.state.objInfo)];
      if (this.filterController.isValid()) {
        promises.push(
          loadPermissions(
            this.filterController.currentFilters,
            this.state.objInfo
          )
        );
      }
      const [fieldInfo, permissions] = await Promise.all(promises);
      this.state.fieldInfo = fieldInfo;
      this.state.objPermissions = permissions?.[0] ?? [];
      this.state.fieldPermissions = permissions?.[1] ?? [];
      processData(this.state);
      this.showTable = true;
    } catch (ex) {
      this.error = reduceErrors(ex);
    } finally {
      this.isLoading = false;
    }
  }

  handleResetFilter(event) {
    event.stopPropagation();
    this.filterController.resetFilters();
    this.applyFilter();
  }

  handleApplyFilter(event) {
    event.stopPropagation();
    this.applyFilter();
  }

  handleClearFilter(event) {
    event.stopPropagation();
    this.filterController.clearFilters();
    this.applyFilter();
  }

  async applyFilter() {
    if (this.filterController.isValid()) {
      try {
        this.isLoading = true;
        const [objPermissions, fieldPermissions] = await loadPermissions(
          this.filterController.currentFilters,
          this.state.objInfo
        );
        this.state.objPermissions = objPermissions;
        this.state.fieldPermissions = fieldPermissions;
        processData(this.state);
        this.filterController.saveToLocalStorage();
        this.template.querySelector("c-permission-table").clearSelection();
      } catch (e) {
        Toast.show(
          {
            label: LABELS.permissions_label_error_unable_to_apply_filters,
            message: reduceErrors(e),
            mode: "sticky",
            variant: "error"
          },
          this
        );
      } finally {
        this.isLoading = false;
      }
    }
  }

  hanldeFilterValueChange(event) {
    event.stopPropagation();
    this.filterController.updateFilters(event.detail);
    this.refs.toolbar.filterValues = this.filters;
  }

  handleSearch({ detail }) {
    const grid = this.template.querySelector("c-permission-table");
    grid.applySearchFilterOnObject(detail);
  }

  handleUpdateObjectCount(event) {
    this.objectCount = event.detail.objectCount;
  }

  handleUpdateFieldCount(event) {
    this.fieldCount = event.detail.fieldCount;
  }

  get filterController() {
    if (!this._filterController) {
      this._filterController = makeFilters(this.localStorageKey);
    }
    return this._filterController;
  }

  get labels() {
    return LABELS;
  }
}
