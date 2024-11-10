class ApplyEvent extends CustomEvent {
  constructor() {
    super(ApplyEvent.type, {
      bubbles: true,
      composed: true
    });
  }
  static get type() {
    return "apply";
  }
}

class ClearEvent extends CustomEvent {
  constructor() {
    super(ClearEvent.type, {
      bubbles: true,
      composed: true
    });
  }
  static get type() {
    return "clear";
  }
}

class ResetEvent extends CustomEvent {
  constructor() {
    super(ResetEvent.type, {
      bubbles: true,
      composed: true
    });
  }
  static get type() {
    return "reset";
  }
}

class FilterChangeEvent extends CustomEvent {
  constructor(detail) {
    super(FilterChangeEvent.type, {
      detail,
      bubbles: true,
      composed: true
    });
  }
  static get type() {
    return "filterchange";
  }
}

export { ApplyEvent, ClearEvent, ResetEvent, FilterChangeEvent };
