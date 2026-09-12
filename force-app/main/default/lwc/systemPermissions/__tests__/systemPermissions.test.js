import { createElement } from "@lwc/engine-dom";
import SystemPermissions from "c/systemPermissions";

describe("c-system-permissions", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders lightning-datatable", () => {
    const element = createElement("c-system-permissions", {
      is: SystemPermissions
    });

    document.body.appendChild(element);

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
