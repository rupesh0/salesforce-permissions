import { LightningElement } from "lwc";
import { reduceErrors } from "c/ldsUtils";
import getCurrentUsersDetails from "@salesforce/apex/MyPermissionsController.getCurrentUsersDetails";
import { LABELS } from "./i18n";

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
    return LABELS;
  }
}
