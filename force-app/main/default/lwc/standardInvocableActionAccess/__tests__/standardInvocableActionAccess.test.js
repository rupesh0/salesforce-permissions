import { createElement } from "lwc";
import StandardInvocableActionAccess from "c/standardInvocableActionAccess";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import getStandardInvocableActionPermissions from "@salesforce/apex/StandardInvocableActionAccessController.getStandardInvocableActionPermissions";

const getStandardInvocableActionPermissionsAdapter =
  registerApexTestWireAdapter(getStandardInvocableActionPermissions);

describe("c-standard-invocable-action-access", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders empty illustration when no records exist", async () => {
    const element = createElement("c-standard-invocable-action-access", {
      is: StandardInvocableActionAccess
    });
    document.body.appendChild(element);

    await Promise.resolve();

    const illustration = element.shadowRoot.querySelector("c-illustration");
    expect(illustration).not.toBeNull();
  });

  it("renders datatable when records are emitted from wire", async () => {
    const element = createElement("c-standard-invocable-action-access", {
      is: StandardInvocableActionAccess
    });
    document.body.appendChild(element);

    getStandardInvocableActionPermissionsAdapter.emit([
      {
        actionId: "action_1",
        actionName: "chatterPost",
        label: "Post to Chatter"
      }
    ]);

    await Promise.resolve();

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
