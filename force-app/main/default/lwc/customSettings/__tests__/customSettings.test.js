import { createElement } from "lwc";
import CustomSettings from "c/customSettings";

describe("c-custom-settings", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders without error", () => {
    const element = createElement("c-custom-settings", {
      is: CustomSettings
    });
    document.body.appendChild(element);
    expect(element).not.toBeNull();
  });
});
