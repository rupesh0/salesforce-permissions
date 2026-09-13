import { api, LightningElement } from "lwc";

export default class AllPermissions extends LightningElement {
  @api profileIds = [];
  @api permissionSetIds = [];
  @api searchTerm = "";
}
