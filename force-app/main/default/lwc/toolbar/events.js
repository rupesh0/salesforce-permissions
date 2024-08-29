class SearchEvent extends CustomEvent {
  constructor(searchTerm) {
    super(SearchEvent.type, {
      detail: searchTerm
    });
  }

  static get type() {
    return "search";
  }
}

class FilterButtonClickEvent extends CustomEvent {
  constructor() {
    super(FilterButtonClickEvent.type);
  }

  static get type() {
    return "filterbuttonclick";
  }
}

export { SearchEvent, FilterButtonClickEvent };
