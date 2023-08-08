import 'package:flutter/material.dart';

import '../../style/area_style.dart';
import '../chart_tween.dart';
import 'color_tween.dart';
import 'shader_tween.dart';

class AreaStyleTween extends ChartTween<AreaStyle> {
  ChartColorTween? _colorTween;
  ChartShaderTween? _chartShaderTween;

  AreaStyleTween(
    super.begin,
    super.end, {
    super.allowCross,
    super.props,
  }) {
    changeValue(begin, end);
  }

  @override
  void changeValue(AreaStyle begin, AreaStyle end) {
    super.changeValue(begin, end);
    _colorTween = null;
    _chartShaderTween = null;
    if (begin.color != null || end.color != null) {
      _colorTween = ChartColorTween((begin.color ?? end.color)!, (end.color ?? begin.color)!);
    }
    if (begin.shader != null || end.shader != null) {
      _chartShaderTween = ChartShaderTween((begin.shader ?? end.shader)!, (end.shader ?? begin.shader)!);
    }
  }

  @override
  AreaStyle convert(double animatorPercent) {
    List<BoxShadow> shadowList = BoxShadow.lerpList(begin.shadow, end.shadow, animatorPercent) ?? [];
    return AreaStyle(
      color: _colorTween?.convert(animatorPercent) ?? (begin.color ?? end.color),
      shadow: shadowList,
      shader: _chartShaderTween?.convert(animatorPercent) ?? (begin.shader ?? end.shader),
    );
  }
}
