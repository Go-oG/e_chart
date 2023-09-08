import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

class BorderTheme {
  Color _color = const Color(0xDD000000);

  Color get color => _color;

  set color(Color c) {
    if (c == _color) {
      return;
    }
    _color = c;
    _style = null;
  }

  num _width = 1;

  num get width => _width;

  set width(num w) {
    if (w == _width) {
      return;
    }
    _width = w;
    _style = null;
  }

  List<num> _dash = [];

  List<num> get dash => _dash;

  set dash(List<num> d) {
    _dash = d;
    _style = null;
  }

  List<BoxShadow> _shadow = [];

  List<BoxShadow> get shadow => _shadow;

  set shadow(List<BoxShadow> d) {
    _shadow = d;
    _style = null;
  }

  ChartShader? _shader;

  ChartShader? get shader => _shader;

  set shader(ChartShader? cs) {
    _shader = cs;
    _style = null;
  }

  num _smooth = 0;

  num get smooth => _smooth;

  set smooth(num b) {
    if (b == _smooth) {
      return;
    }
    _smooth = b;
    _style = null;
  }

  Align2 _align = Align2.center;

  Align2 get align => _align;

  set align(Align2 a) {
    if (a == _align) {
      return;
    }
    _align = a;
    _style = null;
  }

  BorderTheme();

  BorderTheme.any({
    Color color = const Color(0xDD000000),
    num width = 1,
    List<num> dash = const [],
    List<BoxShadow> shadow = const [],
    ChartShader? shader,
    num smooth = 0,
    Align2 align = Align2.center,
  }) {
    _color = color;
    _width = width;
    _dash = dash;
    _shadow = shadow;
    _shader = shader;
    _smooth = smooth;
    _align = align;
  }

  LineStyle? _style;

  LineStyle? getStyle() {
    var s = _style;
    if (s != null) {
      return s;
    }
    if (width <= 0) {
      return null;
    }
    s = LineStyle(
      color: color,
      width: width,
      dash: dash,
      shadow: shadow,
      shader: shader,
      smooth: smooth,
      align: align,
    );
    _style = s;
    return s;
  }
}
