export const PERMISSION_TYPES = {
  OBJECTS: "objects",
  APEX_CLASS: "apexClass",
  VF_PAGE: "vfPage",
  CUSTOM_SETTINGS: "customSettings",
  CUSTOM_METADATA: "customMetadata",
  EXTERNAL_DATA_SOURCES: "externalDataSources",
  FLOW: "flow",
  NAMED_CREDENTIALS: "namedCredentials",
  ASSIGNED_APPS: "assignedApps",
  ASSIGNED_CONNECTED_APPS: "assignedConnectedApps",
  APP_PERMISSIONS: "appPermissions",
  SYSTEM_PERMISSIONS: "systemPermissions",
  ORG_WIDE_EMAIL: "orgWideEmail",
  STANDARD_INVOCABLE_ACTIONS: "standardInvocableActions",
  SERVICE_PROVIDERS: "serviceProviders"
};

export const DEFAULT_TITLES = {
  [PERMISSION_TYPES.OBJECTS]: "Permissions",
  [PERMISSION_TYPES.APEX_CLASS]: "Apex Class Access",
  [PERMISSION_TYPES.VF_PAGE]: "Visualforce Page Access",
  [PERMISSION_TYPES.CUSTOM_SETTINGS]: "Custom Setting Definitions",
  [PERMISSION_TYPES.CUSTOM_METADATA]: "Custom Metadata Types",
  [PERMISSION_TYPES.EXTERNAL_DATA_SOURCES]: "External Data Sources",
  [PERMISSION_TYPES.FLOW]: "Flow Access",
  [PERMISSION_TYPES.NAMED_CREDENTIALS]: "Named Credential Access",
  [PERMISSION_TYPES.ASSIGNED_APPS]: "Assigned Apps",
  [PERMISSION_TYPES.ASSIGNED_CONNECTED_APPS]: "Assigned Connected Apps",
  [PERMISSION_TYPES.APP_PERMISSIONS]: "App Permissions",
  [PERMISSION_TYPES.SYSTEM_PERMISSIONS]: "System Permissions",
  [PERMISSION_TYPES.ORG_WIDE_EMAIL]: "Organization-Wide Email Address Access",
  [PERMISSION_TYPES.STANDARD_INVOCABLE_ACTIONS]:
    "Standard Invocable Action Type Access",
  [PERMISSION_TYPES.SERVICE_PROVIDERS]: "Service Providers"
};
