import { EMPTY_FILTERS } from "./constants";

class Filters {
  _localStorageKey = "";
  _defaultFilters = JSON.parse(JSON.stringify(EMPTY_FILTERS));
  _currentFilters = JSON.parse(JSON.stringify(EMPTY_FILTERS));

  constructor(key) {
    this._localStorageKey = key;
  }

  setDefaults(defaultValues) {
    this._defaultFilters = Object.assign(this._defaultFilters, defaultValues);
  }

  loadFromLocalStorage() {
    const stringValues = window.localStorage.getItem(this._localStorageKey);
    if (!stringValues) {
      this._currentFilters = Object.assign({}, this._defaultFilters);
      return;
    }

    const filterObj = JSON.parse(stringValues);
    this._currentFilters = Object.assign({}, filterObj);
  }

  updateFilters(detail) {
    this._currentFilters = Object.assign(this._currentFilters, detail);
  }

  resetFilters() {
    this._currentFilters = Object.assign({}, this._defaultFilters);
  }

  clearFilters() {
    this._currentFilters = JSON.parse(JSON.stringify(EMPTY_FILTERS));
  }

  saveToLocalStorage() {
    const stringValues = JSON.stringify(this._currentFilters);
    window.localStorage.setItem(this._localStorageKey, stringValues);
  }

  isValid() {
    return true;
  }

  get defaultFilters() {
    return JSON.parse(JSON.stringify(this._defaultFilters));
  }

  get currentFilters() {
    return JSON.parse(JSON.stringify(this._currentFilters));
  }
}

export function makeFilters(localStorageKey) {
  const filters = new Filters(localStorageKey);
  return filters;
}
