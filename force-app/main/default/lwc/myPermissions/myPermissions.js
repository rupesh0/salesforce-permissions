import { LightningElement, track } from "lwc";
import { reduceErrors } from "c/utils";
import getCurrentUsersDetails from "@salesforce/apex/MyPermissionsController.getCurrentUsersDetails";
import { ALL_PERMISSION_KEYS } from "c/permissionVisibilityFilter";
import { LABELS } from "./i18n";

export default class MyPermissions extends LightningElement {
  @track defaultFilters = { profileIds: [], permissionSetIds: [] };
  @track currentFilters = { profileIds: [], permissionSetIds: [] };
  @track appliedFilters = { profileIds: [], permissionSetIds: [] };
  @track visiblePermissions = [...ALL_PERMISSION_KEYS];
  searchTerm = "";
  error;
  isLoading = true;

  async connectedCallback() {
    this.isLoading = true;
    try {
      const result = await getCurrentUsersDetails();
      const filters = {
        profileIds: [result.currentUsersProfileId],
        permissionSetIds: result.currentUsersPermissionSetIds || []
      };
      this.defaultFilters = { ...filters };
      this.currentFilters = { ...filters };
      this.appliedFilters = { ...filters };
    } catch (ex) {
      this.error = reduceErrors(ex);
    } finally {
      this.isLoading = false;
    }
  }

  handleSearch(event) {
    this.searchTerm = event.detail;
  }

  handleFilterChange(event) {
    this.currentFilters = event.detail;
  }

  handleApply() {
    this.appliedFilters = { ...this.currentFilters };
  }

  handleClear() {
    this.currentFilters = { profileIds: [], permissionSetIds: [] };
    this.appliedFilters = { profileIds: [], permissionSetIds: [] };
  }

  handleReset() {
    this.currentFilters = { ...this.defaultFilters };
    this.appliedFilters = { ...this.defaultFilters };
  }

  handleVisibilityChange(event) {
    this.visiblePermissions = event.detail.visiblePermissions;
  }

  get appliedProfileIds() {
    return this.appliedFilters?.profileIds || [];
  }

  get appliedPermissionSetIds() {
    return this.appliedFilters?.permissionSetIds || [];
  }

  get labels() {
    return LABELS;
  }
}
