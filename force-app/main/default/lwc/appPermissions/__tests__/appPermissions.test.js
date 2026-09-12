import { createElement } from "lwc";
import AppPermissions from "c/appPermissions";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import getAppPermissions from "@salesforce/apex/AppPermissionsController.getAppPermissions";

const getAppPermissionsAdapter = registerApexTestWireAdapter(getAppPermissions);

describe("c-app-permissions", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders empty illustration when no records exist", async () => {
    const element = createElement("c-app-permissions", {
      is: AppPermissions
    });
    document.body.appendChild(element);

    await Promise.resolve();

    const illustration = element.shadowRoot.querySelector("c-illustration");
    expect(illustration).not.toBeNull();
  });

  it("renders datatable when records are emitted from wire", async () => {
    const element = createElement("c-app-permissions", {
      is: AppPermissions
    });
    document.body.appendChild(element);

    getAppPermissionsAdapter.emit([
      { apiName: "ManageUsers", label: "Manage Users", description: "Test" }
    ]);

    await Promise.resolve();

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
