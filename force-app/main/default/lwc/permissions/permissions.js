import { api, LightningElement, track } from "lwc";
import Toast from "lightning/toast";
import { loadPermissions, loadObjectInfo, loadFields } from "./dataLoader.js";
import { reduceErrors, stringFormat } from "c/utils";
import { processData } from "./dataProcessor.js";
import { makeFilters } from "./filters.js";
import { LABELS } from "./i18n.js";

export default class Permissions extends LightningElement {
  @api title;

  @api
  get showToolbar() {
    return this._showToolbar;
  }
  set showToolbar(value) {
    this._showToolbar = Boolean(value);
  }

  @api
  get filters() {
    return this.filterController.currentFilters;
  }
  set filters(value) {
    this._showToolbar = true;
    this.filterController.setDefaults(value);
    if (this.state.objInfo.length > 0) {
      this.applyFilter();
    }
  }

  @api
  get profileIds() {
    return this.filterController.currentFilters.profileIds;
  }
  set profileIds(value) {
    this.filterController.updateFilters({ profileIds: value || [] });
    if (this.state.objInfo.length > 0) {
      this.applyFilter();
    }
  }

  @api
  get permissionSetIds() {
    return this.filterController.currentFilters.permissionSetIds;
  }
  set permissionSetIds(value) {
    this.filterController.updateFilters({ permissionSetIds: value || [] });
    if (this.state.objInfo.length > 0) {
      this.applyFilter();
    }
  }

  @api
  get searchTerm() {
    return this._searchTerm;
  }
  set searchTerm(value) {
    this._searchTerm = value;
    const grid = this.template?.querySelector("c-permission-table");
    if (grid) {
      grid.applySearchFilterOnObject(value);
    }
  }

  @track state = {
    objInfo: [],
    fieldInfo: [],
    objPermissions: [],
    fieldPermissions: []
  };

  localStorageKey = "myPermissions";
  _filterController;
  _showToolbar = false;
  _searchTerm = "";
  error;
  showTable;
  isLoading = true;
  objectCount = 0;
  fieldCount = 0;

  async connectedCallback() {
    try {
      this.isLoading = true;
      this.dispatchLoading(true);
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
      this.dispatchEvent(
        new CustomEvent("error", {
          detail: { error: this.error },
          bubbles: true,
          composed: true
        })
      );
    } finally {
      this.isLoading = false;
      this.dispatchLoading(false);
    }
  }

  handleResetFilter(event) {
    event?.stopPropagation();
    this.filterController.resetFilters();
    this.applyFilter();
  }

  handleApplyFilter(event) {
    event?.stopPropagation();
    this.applyFilter();
  }

  handleClearFilter(event) {
    event?.stopPropagation();
    this.filterController.clearFilters();
    this.applyFilter();
  }

  async applyFilter() {
    if (this.filterController.isValid()) {
      try {
        this.isLoading = true;
        this.dispatchLoading(true);
        const [objPermissions, fieldPermissions] = await loadPermissions(
          this.filterController.currentFilters,
          this.state.objInfo
        );
        this.state.objPermissions = objPermissions;
        this.state.fieldPermissions = fieldPermissions;
        processData(this.state);
        this.filterController.saveToLocalStorage();
        const grid = this.template?.querySelector("c-permission-table");
        if (grid) {
          grid.clearSelection();
        }
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
        this.dispatchLoading(false);
      }
    }
  }

  hanldeFilterValueChange(event) {
    event?.stopPropagation();
    this.filterController.updateFilters(event.detail);
    if (this.refs.toolbar) {
      this.refs.toolbar.filterValues = this.filters;
    }
  }

  handleSearch({ detail }) {
    const grid = this.template.querySelector("c-permission-table");
    if (grid) {
      grid.applySearchFilterOnObject(detail);
    }
  }

  handleUpdateObjectCount(event) {
    this.objectCount = event.detail.objectCount;
    this.notifySubtitleChange();
  }

  handleUpdateFieldCount(event) {
    this.fieldCount = event.detail.fieldCount;
    this.notifySubtitleChange();
  }

  notifySubtitleChange() {
    this.dispatchEvent(
      new CustomEvent("subtitlechange", {
        detail: { subTitles: this.subTitles },
        bubbles: true,
        composed: true
      })
    );
  }

  dispatchLoading(isLoading) {
    this.dispatchEvent(
      new CustomEvent("loadingchange", {
        detail: { isLoading },
        bubbles: true,
        composed: true
      })
    );
  }

  get subTitles() {
    return [
      stringFormat(LABELS.common_label_x_objects, this.objectCount),
      stringFormat(LABELS.common_label_x_fields, this.fieldCount)
    ];
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
