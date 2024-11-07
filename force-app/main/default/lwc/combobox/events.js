

class ChangeEvent extends CustomEvent {
    constructor(selectedValues) {
        super(ChangeEvent.type, {detail: {selectedValues}})
    }
    static type() {
        return 'change';
    }
}

export {ChangeEvent}