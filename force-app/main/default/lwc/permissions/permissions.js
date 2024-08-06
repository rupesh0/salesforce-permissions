import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadData } from "./dataLoader.js";

export default class Permissions extends LightningElement {
  @api
  get filters() {
    return this.state.filters;
  }
  set filters(value) {
    this.state.filters = value;
  }

  async connectedCallback() {
    try {
      this.state.data = await loadData();
    } catch (ex) {
      const event = new ShowToastEvent({
        variant: "error",
        title: "Run Time Error",
        message: `An error occurred while loading the data.`
      });
      this.dispatchEvent(event);
    }
  }

  state = {
    filters: {
      profileIds: [],
      permissionSetIds: []
    },
    data: {}
  };
}
