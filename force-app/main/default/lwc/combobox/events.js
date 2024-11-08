class ChangeEvent extends CustomEvent {
  constructor(selectedValues) {
    super(ChangeEvent.type, {
      detail: { selectedValues },
      bubbles: true,
      composed: true
    });
  }
  static get type() {
    return "change";
  }
}

export { ChangeEvent };
