import '../model/view_state.dart';

///https://m3.material.io/foundations/interaction/states/overview
mixin ViewStateProvider {
  final Set<ViewState> _stateSet = {};

  bool get isEnabled => !_stateSet.contains(ViewState.disabled);

  bool get isDisabled => _stateSet.contains(ViewState.disabled);

  bool get isHover => _stateSet.contains(ViewState.hover);

  bool get isFocused => _stateSet.contains(ViewState.focused);

  bool get isActivated => _stateSet.contains(ViewState.activated);

  bool get isPressed => _stateSet.contains(ViewState.pressed);

  bool get isDragged => _stateSet.contains(ViewState.dragged);

  bool get isSelected => _stateSet.contains(ViewState.selected);

  bool _changed = false;

  bool get changed {
    var r = _changed;
    _changed = false;
    return r;
  }

  bool addState(ViewState s) {
    return _changed = _stateSet.add(s);
  }

  bool addStates(Iterable<ViewState> states) {
    bool result = false;
    for (var s in states) {
      if (addState(s)) {
        result = true;
      }
    }
    return _changed = result;
  }

  bool removeState(ViewState s) {
    return _changed = _stateSet.remove(s);
  }

  bool removeStates(Iterable<ViewState> states) {
    bool result = false;
    for (var s in states) {
      if (removeState(s)) {
        result = true;
      }
    }
    return _changed = result;
  }

  bool cleanState() {
    if (_stateSet.isEmpty) {
      return _changed = false;
    }
    _stateSet.clear();
    return _changed = true;
  }

  Set<ViewState> get status => _stateSet;
}

