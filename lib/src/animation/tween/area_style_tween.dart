import 'package:flutter/material.dart';

import '../../style/area_style.dart';
import '../chart_tween.dart';
import 'box_shadow_tween.dart';
import 'color_tween.dart';
import 'line_style_tween.dart';
import 'shader_tween.dart';

class AreaStyleTween extends ChartTween<AreaStyle> {
  ChartColorTween? _colorTween;
  BoxShadowTween? _boxShadowTween;
  LineStyleTween? _lineStyleTween;
  ChartShaderTween? _chartShaderTween;

  AreaStyleTween(super.begin, super.end) {
    changeValue(begin, end);
  }

  @override
  void changeValue(AreaStyle begin, AreaStyle end) {
    super.changeValue(begin, end);
    _colorTween = null;
    _chartShaderTween = null;
    _boxShadowTween = null;
    _lineStyleTween = null;
    if (begin.color != null || end.color != null) {
      _colorTween = ChartColorTween((begin.color ?? end.color)!, (end.color ?? begin.color)!);
    }
    if (begin.shadow != null || end.shadow != null) {
      _boxShadowTween = BoxShadowTween((begin.shadow ?? end.shadow)!, (end.shadow ?? begin.shadow)!);
    }
    if (begin.border != null || end.border != null) {
      _lineStyleTween = LineStyleTween((begin.border ?? end.border)!, (end.border ?? begin.border)!);
    }
    if (begin.shader != null || end.shader != null) {
      _chartShaderTween = ChartShaderTween((begin.shader ?? end.shader)!, (end.shader ?? begin.shader)!);
    }
  }

  @override
  AreaStyle convert(double animatorPercent) {
    BoxShadow? shadow = end.shadow;
    if (_boxShadowTween != null) {
      shadow = _boxShadowTween?.convert(animatorPercent);
    } else {
      if (begin.color != null && end.shadow != null) {
        shadow = BoxShadow(
          color: Color.lerp(begin.color!, end.shadow!.color, animatorPercent)!,
          offset: end.shadow!.offset,
          blurStyle: end.shadow!.blurStyle,
          spreadRadius: end.shadow!.spreadRadius,
          blurRadius: end.shadow!.blurRadius,
        );
      }
    }

    return AreaStyle(
      color: _colorTween?.convert(animatorPercent) ?? (begin.color ?? end.color),
      border: _lineStyleTween?.convert(animatorPercent) ?? (begin.border ?? end.border),
      shadow: shadow,
      shader: _chartShaderTween?.convert(animatorPercent) ?? (begin.shader ?? end.shader),
    );
  }
}
