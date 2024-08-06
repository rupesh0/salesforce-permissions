import { api, LightningElement } from "lwc";

export default class Permissions extends LightningElement {
  @api
  get filters() {
    return this.state.filters;
  }
  set filters(value) {
    this.state.filters = value;
  }

  state = {
    filters: {
      profileIds: [],
      permissionSetIds: []
    }
  };
}
