import { createElement } from "lwc";
import Toolbar from "c/toolbar";

describe("c-toolbar", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders custom title when provided", async () => {
    const element = createElement("c-toolbar", {
      is: Toolbar
    });
    element.title = "App Permissions";
    document.body.appendChild(element);

    await Promise.resolve();

    const titleEl = element.shadowRoot.querySelector(
      ".slds-page-header__title"
    );
    expect(titleEl.textContent).toBe("App Permissions");
  });

  it("renders dynamic subTitles array", async () => {
    const element = createElement("c-toolbar", {
      is: Toolbar
    });
    element.subTitles = ["150 Permissions enabled", "Active"];
    document.body.appendChild(element);

    await Promise.resolve();

    const metaItems = element.shadowRoot.querySelectorAll(".slds-item");
    expect(metaItems.length).toBe(2);
    expect(metaItems[0].textContent).toBe("150 Permissions enabled");
    expect(metaItems[1].textContent).toBe("Active");
  });

  it("toggles filter panel when filter button is clicked", async () => {
    const element = createElement("c-toolbar", {
      is: Toolbar
    });
    element.filterValues = { profileIds: [], permissionSetIds: [] };
    document.body.appendChild(element);

    await Promise.resolve();

    const filterButton = element.shadowRoot.querySelector(
      "lightning-button-icon-stateful"
    );
    filterButton.click();

    await Promise.resolve();

    const filterPanel = element.shadowRoot.querySelector("c-filter-panel");
    expect(filterPanel).not.toBeNull();
  });

  it("dispatches search event on input commit or change", async () => {
    const element = createElement("c-toolbar", {
      is: Toolbar
    });
    document.body.appendChild(element);

    const searchHandler = jest.fn();
    element.addEventListener("search", searchHandler);

    await Promise.resolve();

    const input = element.shadowRoot.querySelector("lightning-input");
    input.value = "test search";
    input.dispatchEvent(new CustomEvent("commit"));

    expect(searchHandler).toHaveBeenCalledTimes(1);
    expect(searchHandler.mock.calls[0][0].detail).toBe("test search");
  });
});
