import 'package:flutter/painting.dart';

///https://m3.material.io/foundations/interaction/states/overview
enum ViewState {
  disabled,
  selected,
  hover,
  focused,
  activated,
  pressed,
  dragged,
}

mixin ViewStateProvider {
  final Set<ViewState> _stateSet = {};

  bool get isEnabled => !_stateSet.contains(ViewState.disabled);

  bool get isDisabled => _stateSet.contains(ViewState.disabled);

  bool get isHover => _stateSet.contains(ViewState.hover);

  bool get isFocused => _stateSet.contains(ViewState.focused);

  bool get isActivated => _stateSet.contains(ViewState.activated);

  bool get isPressed => _stateSet.contains(ViewState.pressed);

  bool get isDragged => _stateSet.contains(ViewState.dragged);

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

abstract class ViewStateResolver<T> {
  T? resolve(Set<ViewState>? states);
}

class ColorResolver extends ViewStateResolver<Color> {
  Color overlay;

  ColorResolver(this.overlay);

  @override
  Color? resolve(Set<ViewState>? states) {
    states ??= {};
    if (states.isEmpty) {
      return overlay;
    }

    if (states.contains(ViewState.disabled)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      return hsv.withSaturation(0).withValue(0.5).toColor();
    }

    if (states.contains(ViewState.hover)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      double v = hsv.value;
      v += 0.16;
      if (v > 1) {
        v = 1;
      }
      return hsv.withValue(v).toColor();
    }

    if (states.contains(ViewState.focused) || states.contains(ViewState.pressed)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      double v = hsv.value;
      v += 0.24;
      if (v > 1) {
        v = 1;
      }
      return hsv.withValue(v).toColor();
    }

    if (states.contains(ViewState.dragged)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      return hsv.withValue(0.16).toColor();
    }

    return overlay;
  }
}
