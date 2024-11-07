import { LightningElement, api } from "lwc";
import { debounce } from "./utils";
import { ChangeEvent } from "./events";

export default class Combobox extends LightningElement {
  @api label;
  @api placeholder = "Search...";
  @api options;
  @api selectedValues = [];

  filteredOptions = [];
  toggleOptions = false;

  connectedCallback() {
    this.filteredOptions = this.options?.slice(0) ?? [];
  }

  handleFocus() {
    this.toggleOptions = true;
  }

  handleBlur() {
	debounce(() => {
		this.toggleOptions = false;
	  })();
  }

  handleSelect(event) {
    const selectedValue = event.currentTarget.dataset.rowid;
    this.selectedValues.push(selectedValue);	
    this.toggleOptions = false;

    this.dispatchEvent(new ChangeEvent(this.selectedValues));
  }

  handleChangeSearchTerm(event) {
    const searchTerm = event.target.value;
    debounce(() => {
      this.filteredOptions = this.options.filter(
        (option) =>
          searchTerm === "" ||
          option.label.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }, 300)();
    this.toggleOptions = true;
  }

  handleItemRemove(event) {
	const index = event.detail.index;
	this.selectedValues.splice(index, 1);
	this.selectedValues = [...this.selectedValues]
}

  get selectedOptions() {
	return this.selectedValues.map((value)=> {
		return  this.options.find(option => value === option.value)
	})
  }

  get showOptions() {
    return this.toggleOptions && this.optionsToShow.length;
  }

  get optionsToShow() {
	return this.filteredOptions.filter(option => !this.selectedValues.includes(option.value))
  }

  get labels() {
    return {
      iconAltText: "Search"
    };
  }
}
