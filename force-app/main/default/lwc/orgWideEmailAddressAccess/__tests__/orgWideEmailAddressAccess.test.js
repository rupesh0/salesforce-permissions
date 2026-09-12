import { createElement } from "lwc";
import OrgWideEmailAddressAccess from "c/orgWideEmailAddressAccess";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import getOrgWideEmailAddressPermissions from "@salesforce/apex/OrgWideEmailAddressAccessController.getOrgWideEmailAddressPermissions";

const getOrgWideEmailAddressPermissionsAdapter = registerApexTestWireAdapter(
  getOrgWideEmailAddressPermissions
);

describe("c-org-wide-email-address-access", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders empty illustration when no records exist", async () => {
    const element = createElement("c-org-wide-email-address-access", {
      is: OrgWideEmailAddressAccess
    });
    document.body.appendChild(element);

    await Promise.resolve();

    const illustration = element.shadowRoot.querySelector("c-illustration");
    expect(illustration).not.toBeNull();
  });

  it("renders datatable when records are emitted from wire", async () => {
    const element = createElement("c-org-wide-email-address-access", {
      is: OrgWideEmailAddressAccess
    });
    document.body.appendChild(element);

    getOrgWideEmailAddressPermissionsAdapter.emit([
      {
        id: "0D2000000000001",
        displayName: "Support",
        address: "support@example.com",
        purpose: "UserAndDefaultNoReply"
      }
    ]);

    await Promise.resolve();

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
