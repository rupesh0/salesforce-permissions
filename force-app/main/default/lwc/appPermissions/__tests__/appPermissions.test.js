import { createElement } from "@lwc/engine-dom";
import AppPermissions from "c/appPermissions";

describe("c-app-permissions", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders lightning-datatable", () => {
    const element = createElement("c-app-permissions", {
      is: AppPermissions
    });

    document.body.appendChild(element);

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
