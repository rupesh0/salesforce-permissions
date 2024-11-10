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

export { SearchEvent };
