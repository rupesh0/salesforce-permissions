export const EMPTY_FILTERS = {
  profileIds: [],
  permissionSetIds: []
};

export class Filters {
  _localStorageKey = "";
  _defaultFilters = JSON.parse(JSON.stringify(EMPTY_FILTERS));
  _currentFilters = JSON.parse(JSON.stringify(EMPTY_FILTERS));

  constructor(key) {
    this._localStorageKey = key || "default_permissions";
  }

  setDefaults(defaultValues) {
    if (defaultValues) {
      this._defaultFilters = Object.assign(
        {},
        JSON.parse(JSON.stringify(EMPTY_FILTERS)),
        defaultValues
      );
      this._currentFilters = Object.assign({}, this._defaultFilters);
    }
  }

  loadFromLocalStorage() {
    try {
      const stringValues = window.localStorage?.getItem(this._localStorageKey);
      if (!stringValues) {
        this._currentFilters = Object.assign({}, this._defaultFilters);
        return;
      }

      const filterObj = JSON.parse(stringValues);
      this._currentFilters = Object.assign(
        {},
        JSON.parse(JSON.stringify(EMPTY_FILTERS)),
        filterObj
      );
    } catch {
      this._currentFilters = Object.assign({}, this._defaultFilters);
    }
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
    try {
      const stringValues = JSON.stringify(this._currentFilters);
      window.localStorage?.setItem(this._localStorageKey, stringValues);
    } catch {
      // Ignore localStorage errors (quota or private mode)
    }
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
  return new Filters(localStorageKey);
}
