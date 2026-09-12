import { createElement } from "lwc";
import Permissions from "c/permissions";

describe("c-permissions", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("mounts cleanly and does not render fallback c-toolbar", () => {
    const element = createElement("c-permissions", {
      is: Permissions
    });
    element.profileIds = ["00e000000000001AAA"];
    element.permissionSetIds = ["0PS000000000001AAA"];

    document.body.appendChild(element);

    const toolbar = element.shadowRoot.querySelector("c-toolbar");
    expect(toolbar).toBeNull();
  });
});
