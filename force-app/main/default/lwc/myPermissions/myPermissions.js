import { LightningElement } from "lwc";
import getCurrentUsersDetails from "@salesforce/apex/MyPermissionsController.getCurrentUsersDetails";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MyPermissions extends LightningElement {
  filters = {};

  async connectedCallback() {
    try {
      const result = await getCurrentUsersDetails();
      this.filters = {
        profileIds: [result.currentUsersProfileId],
        PermissionSetIds: result.currentUsersPermissionSetIds
      };
    } catch (ex) {
      const event = new ShowToastEvent({
        variant: "error",
        title: "Run Time Error",
        message: `An error occurred while fetching the current user details.`
      });
      this.dispatchEvent(event);
    }
  }
}
