import { api, LightningElement, track } from "lwc";
import { loadPermissions, loadObjectInfo, loadFields } from "./dataLoader.js";
import { reduceErrors } from "c/ldsUtils";
import { processData } from "./dataProcessor.js";

export default class Permissions extends LightningElement {
  @api
  get filters() {
    return this.state.filters;
  }
  set filters(value) {
    this.state.filters = JSON.parse(JSON.stringify(value));
  }

  @track state = {
    filters: {
      profileIds: [],
      permissionSetIds: []
    },
    objInfo: [],
    fieldInfo: [],
    objPermissions: [],
    fieldPermissions: []
  };

  isFilterButtonSelected = false;
  error;
  showTable;
  isLoading = true;

  async connectedCallback() {
    try {
      this.isLoading = true;
      this.state.objInfo = await loadObjectInfo();
      await Promise.all([loadFields(this.state), loadPermissions(this.state)]);
      processData(this.state);
      this.state = { ...this.state };
      this.showTable = true;
    } catch (ex) {
      this.error = reduceErrors(ex);
    } finally {
      this.isLoading = false;
    }
  }

  handleFilterButtonClick() {
    this.isFilterButtonSelected = !this.isFilterButtonSelected;
  }

  handleSearch({ detail }) {
    const grid = this.template.querySelector("c-permission-table");
    grid.selectedObject = null;
    grid.objectPermissions = this.state.objPermissions.filter((fp) =>
      fp.label.toLocaleLowerCase().includes(detail.toLocaleLowerCase())
    );
  }

  get labels() {
    return {
      error: "An error occurred while loading the data: {0}",
      runTimeError: "Run Time Error",
      permissions: "Permissions",
      loading: "Loading"
    };
  }

  get objectCount() {
    return this.state.objInfo.length;
  }

  get fieldCount() {
    return this.state.fieldInfo.length;
  }
}
