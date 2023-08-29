import 'package:flutter/material.dart';

import '../style/label.dart';

class LabelTheme {
  Color _textColor = const Color(0xDD000000);
  double _textSize = 13;

  LabelTheme();

  LabelTheme.of(Color textColor, double textSize) {
    _textColor = textColor;
    _textSize = textSize;
  }

  Color get textColor => _textColor;

  double get textSize => _textSize;

  set textColor(Color c) {
    if (c == _textColor) {
      return;
    }
    _textColor = c;
    _textStyle = null;
  }

  set textSize(double size) {
    if (size == _textSize) {
      return;
    }
    _textStyle = null;
    _textSize = size;
  }

  LabelStyle? _textStyle;

  LabelStyle getStyle() {
    var style = _textStyle;
    if (style != null) {
      return style;
    }
    style = LabelStyle(textStyle: TextStyle(color: _textColor, fontSize: _textSize));
    _textStyle = style;
    return style;
  }
}
