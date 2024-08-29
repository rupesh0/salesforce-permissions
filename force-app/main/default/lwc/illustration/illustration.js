import { LightningElement, api } from "lwc";
import BASE from "./base.html";

export default class Illustration extends LightningElement {
  @api title;
  @api subTitle;

  @api type = "base";

  render() {
    if (this.type === "base") {
      return BASE;
    }
    return BASE;
  }
}
