class UpdateObjectCountEvent extends CustomEvent {
  constructor(objectCount) {
    super(UpdateObjectCountEvent.type, {
      detail: { objectCount }
    });
  }
  static get type() {
    return "updateobjectcount";
  }
}

class UpdateFieldCountEvent extends CustomEvent {
  constructor(fieldCount) {
    super(UpdateFieldCountEvent.type, {
      detail: { fieldCount }
    });
  }
  static get type() {
    return "updatefieldcount";
  }
}

export { UpdateObjectCountEvent, UpdateFieldCountEvent };
