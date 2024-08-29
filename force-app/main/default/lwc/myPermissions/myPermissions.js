import { LightningElement } from "lwc";
import { reduceErrors } from "c/ldsUtils";
import getCurrentUsersDetails from "@salesforce/apex/MyPermissionsController.getCurrentUsersDetails";

export default class MyPermissions extends LightningElement {
  filters;
  error;
  isLoading;

  async connectedCallback() {
    this.isLoading = true;
    try {
      const result = await getCurrentUsersDetails();
      this.filters = {
        profileIds: [result.currentUsersProfileId],
        permissionSetIds: result.currentUsersPermissionSetIds
      };
    } catch (ex) {
      this.error = reduceErrors(ex);
    } finally {
      this.isLoading = false;
    }
  }

  get labels() {
    return {
      error: "An error occurred while fetching the current user details.",
      loading: "Loading"
    };
  }
}
