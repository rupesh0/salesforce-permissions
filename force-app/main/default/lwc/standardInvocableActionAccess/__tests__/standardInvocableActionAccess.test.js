import { createElement } from "@lwc/engine-dom";
import StandardInvocableActionAccess from "c/standardInvocableActionAccess";

describe("c-standard-invocable-action-access", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders lightning-datatable", () => {
    const element = createElement("c-standard-invocable-action-access", {
      is: StandardInvocableActionAccess
    });

    document.body.appendChild(element);

    const datatable = element.shadowRoot.querySelector("lightning-datatable");
    expect(datatable).not.toBeNull();
  });
});
