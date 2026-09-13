import { api, LightningElement, track } from "lwc";

export const PERMISSION_CONFIG = [
  { key: "object", label: "Object", title: "Object & Field Permissions" },
  { key: "system", label: "System Permissions", title: "System Permissions" },
  { key: "apps", label: "App Permissions", title: "App Permissions" },
  { key: "apexClass", label: "Apex Class", title: "Apex Class Access" },
  {
    key: "vfPage",
    label: "Visualforce Page",
    title: "Visualforce Page Access"
  },
  {
    key: "customSettings",
    label: "Custom Settings",
    title: "Custom Setting Definitions"
  },
  {
    key: "customMetadata",
    label: "Custom Metadata",
    title: "Custom Metadata Types"
  },
  { key: "flow", label: "Flow Access", title: "Flow Access" },
  {
    key: "namedCredentials",
    label: "Named Credentials",
    title: "Named Credential Access"
  },
  {
    key: "orgWideEmail",
    label: "Org-Wide Email",
    title: "Organization-Wide Email Address Access"
  },
  {
    key: "invocableActions",
    label: "Invocable Actions",
    title: "Standard Invocable Action Type Access"
  },
  {
    key: "serviceProviders",
    label: "Service Providers",
    title: "Service Providers"
  },
  { key: "assignedApps", label: "Assigned Apps", title: "Assigned Apps" },
  {
    key: "connectedApps",
    label: "Connected Apps",
    title: "Assigned Connected Apps"
  },
  {
    key: "dataSources",
    label: "External Data Sources",
    title: "External Data Sources"
  }
];

export const ALL_PERMISSION_KEYS = PERMISSION_CONFIG.map((p) => p.key);

export default class PermissionVisibilityFilter extends LightningElement {
  @track localSelectedKeys = [...ALL_PERMISSION_KEYS];
  _visiblePermissions = null;

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
      this._visiblePermissions = null;
    }
  }

  get activeKeys() {
    const keys =
      this._visiblePermissions !== null &&
      this._visiblePermissions !== undefined
        ? this._visiblePermissions
        : this.localSelectedKeys;
    return new Set(keys);
  }

  get permissionOptions() {
    const active = this.activeKeys;
    return PERMISSION_CONFIG.map((cfg) => ({
      ...cfg,
      checked: active.has(cfg.key)
    }));
  }

  get selectedCount() {
    return this.activeKeys.size;
  }

  get totalCount() {
    return PERMISSION_CONFIG.length;
  }

  handleCheckboxChange(event) {
    const key = event.target.name;
    const checked = event.target.checked;
    const newKeys = new Set(this.activeKeys);
    if (checked) {
      newKeys.add(key);
    } else {
      newKeys.delete(key);
    }
    const updated = Array.from(newKeys);
    this.localSelectedKeys = updated;
    this.dispatchChange(updated);
  }

  handleSelectAll() {
    const updated = [...ALL_PERMISSION_KEYS];
    this.localSelectedKeys = updated;
    this.dispatchChange(updated);
  }

  handleClearAll() {
    const updated = [];
    this.localSelectedKeys = updated;
    this.dispatchChange(updated);
  }

  dispatchChange(keys) {
    this.dispatchEvent(
      new CustomEvent("visibilitychange", {
        detail: { visiblePermissions: keys }
      })
    );
  }
}
