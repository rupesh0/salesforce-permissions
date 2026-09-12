import { reduceErrors, stringFormat } from "c/utils";

describe("c-utils", () => {
  it("formats strings with placeholders correctly", () => {
    const formatted = stringFormat("{0} Objects and {1} Fields", 10, 20);
    expect(formatted).toBe("10 Objects and 20 Fields");
  });

  it("reduces error object cleanly", () => {
    const errorObj = { message: "Something went wrong" };
    const reduced = reduceErrors(errorObj);
    expect(reduced).toEqual(["Something went wrong"]);
  });
});
