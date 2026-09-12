import { createElement } from "@lwc/engine-dom";
import ServiceProviders from "c/serviceProviders";

describe("c-service-providers", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders lightning-datatable", () => {
    const element = createElement("c-service-providers", {
      is: ServiceProviders
    });

    document.body.appendChild(element);

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
