import { api, LightningElement } from "lwc";
import { ALL_PERMISSION_KEYS } from "c/permissionVisibilityFilter";

export default class AllPermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];
  @api searchTerm = "";

  _visiblePermissions = [...ALL_PERMISSION_KEYS];

  @api
  get visiblePermissions() {
    return this._visiblePermissions;
  }
  set visiblePermissions(val) {
    if (Array.isArray(val)) {
      this._visiblePermissions = [...val];
    } else if (val) {
      this._visiblePermissions = [val];
    } else {
      this._visiblePermissions = [];
    }
  }

  get activeKeys() {
    return new Set(this._visiblePermissions);
  }

  get isObjectVisible() {
    return this.activeKeys.has("object");
  }

  get isSystemVisible() {
    return this.activeKeys.has("system");
  }

  get isAppsVisible() {
    return this.activeKeys.has("apps");
  }

  get isApexClassVisible() {
    return this.activeKeys.has("apexClass");
  }

  get isVfPageVisible() {
    return this.activeKeys.has("vfPage");
  }

  get isCustomSettingsVisible() {
    return this.activeKeys.has("customSettings");
  }

  get isCustomMetadataVisible() {
    return this.activeKeys.has("customMetadata");
  }

  get isFlowVisible() {
    return this.activeKeys.has("flow");
  }

  get isNamedCredentialsVisible() {
    return this.activeKeys.has("namedCredentials");
  }

  get isOrgWideEmailVisible() {
    return this.activeKeys.has("orgWideEmail");
  }

  get isInvocableActionsVisible() {
    return this.activeKeys.has("invocableActions");
  }

  get isServiceProvidersVisible() {
    return this.activeKeys.has("serviceProviders");
  }

  get isAssignedAppsVisible() {
    return this.activeKeys.has("assignedApps");
  }

  get isConnectedAppsVisible() {
    return this.activeKeys.has("connectedApps");
  }

  get isDataSourcesVisible() {
    return this.activeKeys.has("dataSources");
  }

  get isNoneVisible() {
    return this.activeKeys.size === 0;
  }
}
