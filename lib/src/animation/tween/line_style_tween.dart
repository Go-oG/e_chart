import 'package:xchart/src/component/shader/shader.dart' as sd;
import 'package:flutter/material.dart';
import 'dart:ui' as ui show lerpDouble;

import '../../style/line_style.dart';
import '../chart_tween.dart';
import 'box_shadow_tween.dart';
import 'shader_tween.dart';

class LineStyleTween extends ChartTween<LineStyle> {
  BoxShadowTween? _shadowTween;
  ChartShaderTween? _shaderTween;

  LineStyleTween(super.begin, super.end) {
    changeValue(begin, end);
  }

  @override
  void changeValue(LineStyle begin, LineStyle end) {
    super.changeValue(begin, end);
    if (begin.shadow != null && end.shadow != null) {
      _shadowTween = BoxShadowTween(begin.shadow!, end.shadow!);
    }
    if (begin.shader != null && end.shader != null) {
      _shaderTween = ChartShaderTween(begin.shader!, end.shader!);
    }
  }

  @override
  LineStyle convert(double animatorPercent) {
    List<double> dash;
    if (begin.dash.length == end.dash.length && begin.dash.isNotEmpty) {
      dash = [];
      for (int i = 0; i < begin.dash.length; i++) {
        dash.add(ui.lerpDouble(begin.dash[i], end.dash[i], animatorPercent)!);
      }
    } else {
      dash = animatorPercent < 0.5 ? begin.dash : end.dash;
    }

    BoxShadow? shadow;
    if (_shadowTween != null) {
      shadow = _shadowTween!.value;
    } else {
      shadow = animatorPercent < 0.5 ? begin.shadow : end.shadow;
    }

    sd.Shader? shader;
    if (_shaderTween != null) {
      shader = _shaderTween!.convert(animatorPercent);
    } else {
      shader = animatorPercent < 0.5 ? begin.shader : end.shader;
    }

    return LineStyle(
      color: Color.lerp(begin.color, end.color, animatorPercent)!,
      width: ui.lerpDouble(begin.width, end.width, animatorPercent)!,
      cap: begin.cap == StrokeCap.butt ? end.cap : begin.cap,
      join: begin.join == StrokeJoin.miter ? end.join : begin.join,
      dash: dash,
      shadow: shadow,
      shader: shader,
      smooth: animatorPercent < 0.5 ? begin.smooth : end.smooth,
    );
  }
}
