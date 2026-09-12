import { api, LightningElement, track } from "lwc";
import { loadPermissions, loadObjectInfo, loadFields } from "./dataLoader.js";
import { reduceErrors, stringFormat } from "c/utils";
import { processData } from "./dataProcessor.js";
import { LABELS } from "./i18n.js";

export default class Permissions extends LightningElement {
  @api
  get profileIds() {
    return this._profileIds;
  }
  set profileIds(value) {
    this._profileIds = value || [];
    if (this._isInitialized && this.state.objInfo.length > 0) {
      this.applyFilter();
    }
  }

  @api
  get permissionSetIds() {
    return this._permissionSetIds;
  }
  set permissionSetIds(value) {
    this._permissionSetIds = value || [];
    if (this._isInitialized && this.state.objInfo.length > 0) {
      this.applyFilter();
    }
  }

  @api
  get filters() {
    return {
      profileIds: this._profileIds,
      permissionSetIds: this._permissionSetIds
    };
  }
  set filters(value) {
    this._profileIds = value?.profileIds || [];
    this._permissionSetIds = value?.permissionSetIds || [];
    if (this._isInitialized && this.state.objInfo.length > 0) {
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

  _profileIds = [];
  _permissionSetIds = [];
  _searchTerm = "";
  _isInitialized = false;
  error;
  showTable = false;
  isLoading = true;
  objectCount = 0;
  fieldCount = 0;

  async connectedCallback() {
    try {
      this.isLoading = true;
      this.dispatchLoading(true);
      this.state.objInfo = await loadObjectInfo();
      const promises = [loadFields(this.state.objInfo)];
      if (this.hasFilters) {
        promises.push(
          loadPermissions(
            {
              profileIds: this._profileIds,
              permissionSetIds: this._permissionSetIds
            },
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
      this._isInitialized = true;
      if (this._searchTerm) {
        const grid = this.template?.querySelector("c-permission-table");
        if (grid) {
          grid.applySearchFilterOnObject(this._searchTerm);
        }
      }
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

  get hasFilters() {
    return (
      (this._profileIds && this._profileIds.length > 0) ||
      (this._permissionSetIds && this._permissionSetIds.length > 0)
    );
  }

  async applyFilter() {
    try {
      this.isLoading = true;
      this.dispatchLoading(true);
      if (this.hasFilters) {
        const [objPermissions, fieldPermissions] = await loadPermissions(
          {
            profileIds: this._profileIds,
            permissionSetIds: this._permissionSetIds
          },
          this.state.objInfo
        );
        this.state.objPermissions = objPermissions;
        this.state.fieldPermissions = fieldPermissions;
      } else {
        this.state.objPermissions = [];
        this.state.fieldPermissions = [];
      }
      processData(this.state);
      const grid = this.template?.querySelector("c-permission-table");
      if (grid) {
        grid.clearSelection();
        if (this._searchTerm) {
          grid.applySearchFilterOnObject(this._searchTerm);
        }
      }
    } catch (e) {
      this.error = reduceErrors(e);
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

  get labels() {
    return LABELS;
  }
}
