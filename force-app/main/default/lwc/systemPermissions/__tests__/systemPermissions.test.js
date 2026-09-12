import { createElement } from "lwc";
import SystemPermissions from "c/systemPermissions";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import getSystemPermissions from "@salesforce/apex/SystemPermissionsController.getSystemPermissions";

const getSystemPermissionsAdapter =
  registerApexTestWireAdapter(getSystemPermissions);

describe("c-system-permissions", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders empty illustration when no records exist", async () => {
    const element = createElement("c-system-permissions", {
      is: SystemPermissions
    });
    document.body.appendChild(element);

    await Promise.resolve();

    const illustration = element.shadowRoot.querySelector("c-illustration");
    expect(illustration).not.toBeNull();
  });

  it("renders datatable when records are emitted from wire", async () => {
    const element = createElement("c-system-permissions", {
      is: SystemPermissions
    });
    document.body.appendChild(element);

    getSystemPermissionsAdapter.emit([
      {
        apiName: "ModifyAllData",
        label: "Modify All Data",
        description: "Test"
      }
    ]);

    await Promise.resolve();

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
