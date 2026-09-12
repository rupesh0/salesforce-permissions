import { api, LightningElement, track } from "lwc";
import Toast from "lightning/toast";
import { makeFilters, reduceErrors } from "c/utils";
import { PERMISSION_TYPES, DEFAULT_TITLES } from "./constants";
import { LABELS } from "./i18n";

export default class PermissionContainer extends LightningElement {
  @api permissionType = PERMISSION_TYPES.OBJECTS;
  @api title;
  @api storageKeyPrefix = "permission_filters";

  @api
  get defaultFilters() {
    return this.filterController.defaultFilters;
  }
  set defaultFilters(value) {
    this._defaultFilters = value;
    if (this._filterController) {
      this._filterController.setDefaults(value);
      this.appliedFilters = { ...this._filterController.currentFilters };
      if (this.refs.toolbar) {
        this.refs.toolbar.filterValues = this._filterController.currentFilters;
      }
    }
  }

  @track appliedFilters = {
    profileIds: [],
    permissionSetIds: []
  };

  _defaultFilters;
  _filterController;
  subTitles = [];
  searchTerm = "";
  error;
  isLoading = false;

  connectedCallback() {
    this.filterController.loadFromLocalStorage();
    if (this._defaultFilters) {
      this.filterController.setDefaults(this._defaultFilters);
    }
    this.appliedFilters = this.filterController.currentFilters;
  }

  handleApplyFilter(event) {
    event?.stopPropagation();
    try {
      this.filterController.saveToLocalStorage();
      this.appliedFilters = this.filterController.currentFilters;
      this.isLoading = true;
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
    }
  }

  handleClearFilter(event) {
    event?.stopPropagation();
    this.filterController.clearFilters();
    this.appliedFilters = this.filterController.currentFilters;
    this.isLoading = true;
  }

  handleResetFilter(event) {
    event?.stopPropagation();
    this.filterController.resetFilters();
    this.appliedFilters = this.filterController.currentFilters;
    this.isLoading = true;
  }

  handleFilterValueChange(event) {
    event?.stopPropagation();
    this.filterController.updateFilters(event.detail);
    if (this.refs.toolbar) {
      this.refs.toolbar.filterValues = this.filterController.currentFilters;
    }
  }

  handleSearch(event) {
    this.searchTerm = event.detail;
  }

  handleSubtitleChange(event) {
    event.stopPropagation();
    this.subTitles = event.detail.subTitles || [];
  }

  handleLoadingChange(event) {
    event.stopPropagation();
    this.isLoading = Boolean(event.detail?.isLoading);
  }

  handleChildError(event) {
    event.stopPropagation();
    this.error = reduceErrors(event.detail?.error);
    this.isLoading = false;
  }

  get currentFilters() {
    return this.filterController.currentFilters;
  }

  get appliedProfileIds() {
    return this.appliedFilters?.profileIds || [];
  }

  get appliedPermissionSetIds() {
    return this.appliedFilters?.permissionSetIds || [];
  }

  get filterController() {
    if (!this._filterController) {
      const prefix = this.storageKeyPrefix || "permission_filters";
      const key = `${prefix}_${this.permissionType || "default"}`;
      this._filterController = makeFilters(key);
      if (this._defaultFilters) {
        this._filterController.setDefaults(this._defaultFilters);
      }
    }
    return this._filterController;
  }

  get pageTitle() {
    return (
      this.title ||
      DEFAULT_TITLES[this.permissionType] ||
      DEFAULT_TITLES[PERMISSION_TYPES.OBJECTS]
    );
  }

  get labels() {
    return LABELS;
  }

  get isObjects() {
    return this.permissionType === PERMISSION_TYPES.OBJECTS;
  }

  get isApexClass() {
    return this.permissionType === PERMISSION_TYPES.APEX_CLASS;
  }

  get isVfPage() {
    return this.permissionType === PERMISSION_TYPES.VF_PAGE;
  }

  get isCustomSettings() {
    return this.permissionType === PERMISSION_TYPES.CUSTOM_SETTINGS;
  }

  get isCustomMetadata() {
    return this.permissionType === PERMISSION_TYPES.CUSTOM_METADATA;
  }

  get isExternalDataSources() {
    return this.permissionType === PERMISSION_TYPES.EXTERNAL_DATA_SOURCES;
  }

  get isFlow() {
    return this.permissionType === PERMISSION_TYPES.FLOW;
  }

  get isNamedCredentials() {
    return this.permissionType === PERMISSION_TYPES.NAMED_CREDENTIALS;
  }

  get isAssignedApps() {
    return this.permissionType === PERMISSION_TYPES.ASSIGNED_APPS;
  }

  get isAssignedConnectedApps() {
    return this.permissionType === PERMISSION_TYPES.ASSIGNED_CONNECTED_APPS;
  }

  get isAppPermissions() {
    return this.permissionType === PERMISSION_TYPES.APP_PERMISSIONS;
  }

  get isSystemPermissions() {
    return this.permissionType === PERMISSION_TYPES.SYSTEM_PERMISSIONS;
  }

  get isOrgWideEmail() {
    return this.permissionType === PERMISSION_TYPES.ORG_WIDE_EMAIL;
  }

  get isStandardInvocableActions() {
    return this.permissionType === PERMISSION_TYPES.STANDARD_INVOCABLE_ACTIONS;
  }

  get isServiceProviders() {
    return this.permissionType === PERMISSION_TYPES.SERVICE_PROVIDERS;
  }
}
