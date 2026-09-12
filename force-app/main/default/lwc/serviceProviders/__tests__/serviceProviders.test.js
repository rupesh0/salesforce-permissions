import { createElement } from "lwc";
import ServiceProviders from "c/serviceProviders";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import getServiceProviderPermissions from "@salesforce/apex/ServiceProvidersController.getServiceProviderPermissions";

const getServiceProviderPermissionsAdapter = registerApexTestWireAdapter(
  getServiceProviderPermissions
);

describe("c-service-providers", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders empty illustration when no records exist", async () => {
    const element = createElement("c-service-providers", {
      is: ServiceProviders
    });
    document.body.appendChild(element);

    await Promise.resolve();

    const illustration = element.shadowRoot.querySelector("c-illustration");
    expect(illustration).not.toBeNull();
  });

  it("renders datatable when records are emitted from wire", async () => {
    const element = createElement("c-service-providers", {
      is: ServiceProviders
    });
    document.body.appendChild(element);

    getServiceProviderPermissionsAdapter.emit([
      {
        serviceProviderId: "sp_1",
        serviceProviderName: "Google",
        startUrl: "https://google.com"
      }
    ]);

    await Promise.resolve();

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
