import 'package:flutter/painting.dart';

import '../model/view_state.dart';
import 'state_resolver.dart';

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
