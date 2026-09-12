import { createElement } from "@lwc/engine-dom";
import OrgWideEmailAddressAccess from "c/orgWideEmailAddressAccess";

describe("c-org-wide-email-address-access", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders lightning-datatable", () => {
    const element = createElement("c-org-wide-email-address-access", {
      is: OrgWideEmailAddressAccess
    });

    document.body.appendChild(element);

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
