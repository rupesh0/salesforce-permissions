import { createElement } from "lwc";
import PermissionContainer from "c/permissionContainer";

describe("c-permission-container", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders toolbar with default permissions title", async () => {
    const element = createElement("c-permission-container", {
      is: PermissionContainer
    });
    element.permissionType = "objects";
    document.body.appendChild(element);

    await Promise.resolve();

    const toolbar = element.shadowRoot.querySelector("c-toolbar");
    expect(toolbar).not.toBeNull();
    expect(toolbar.title).toBe("Permissions");
  });

  it("updates subtitle when child emits subtitlechange", async () => {
    const element = createElement("c-permission-container", {
      is: PermissionContainer
    });
    element.permissionType = "apexClass";
    document.body.appendChild(element);

    await Promise.resolve();

    const apexComponent = element.shadowRoot.querySelector(
      "c-apex-class-permissions"
    );
    expect(apexComponent).not.toBeNull();

    apexComponent.dispatchEvent(
      new CustomEvent("subtitlechange", {
        detail: { subTitles: ["25 Apex Classes"] },
        bubbles: true,
        composed: true
      })
    );

    await Promise.resolve();

    const toolbar = element.shadowRoot.querySelector("c-toolbar");
    expect(toolbar.subTitles).toEqual(["25 Apex Classes"]);
  });

  it("handles loadingchange event", async () => {
    const element = createElement("c-permission-container", {
      is: PermissionContainer
    });
    element.permissionType = "apexClass";
    document.body.appendChild(element);

    await Promise.resolve();

    const apexComponent = element.shadowRoot.querySelector(
      "c-apex-class-permissions"
    );

    apexComponent.dispatchEvent(
      new CustomEvent("loadingchange", {
        detail: { isLoading: true },
        bubbles: true,
        composed: true
      })
    );

    await Promise.resolve();

    const spinner = element.shadowRoot.querySelector("lightning-spinner");
    expect(spinner).not.toBeNull();
  });
});
