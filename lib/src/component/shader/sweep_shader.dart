import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/view_state.dart';
import 'shader.dart';

class SweepShader extends ChartShader {
  double startAngle;
  double endAngle;

  SweepShader(
    super.colors, {
    this.startAngle = 0,
    this.endAngle = 360,
    super.colorStops,
    super.tileMode = TileMode.clamp,
    super.matrix4,
  });

  @override
  ui.Shader toShader(Rect rect) {
    Offset center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
    double sa = pi * startAngle / 180.0;
    double ea = pi * endAngle / 180.0;
    return ui.Gradient.sweep(center, colors, colorStops, tileMode, sa, ea, matrix4);
  }

  @override
  ChartShader lerp(covariant SweepShader begin, covariant SweepShader end, double animatorPercent) {
    List<Color> colorList = ChartShader.lerpColors(begin.colors, end.colors, animatorPercent);
    List<double>? stepList = ChartShader.lerpDoubles(begin.colorStops, end.colorStops, animatorPercent);
    Float64List? ma = ChartShader.lerpMatrix4(begin.matrix4, end.matrix4, animatorPercent);
    return SweepShader(
      colorList,
      colorStops: stepList,
      tileMode: begin.tileMode == TileMode.clamp ? end.tileMode : begin.tileMode,
      startAngle: lerpDouble(begin.startAngle, end.startAngle, animatorPercent)!,
      endAngle: lerpDouble(begin.endAngle, end.endAngle, animatorPercent)!,
      matrix4: ma,
    );
  }

  @override
  ChartShader convert(Set<ViewState>? states) {
    if (states == null || states.isEmpty) {
      return this;
    }
    List<Color> cl = [];
    var resolver = ColorResolver(Colors.white);
    for (var c in colors) {
      resolver.overlay = c;
      cl.add(resolver.resolve(states)!);
    }
    return SweepShader(
      cl,
      colorStops: colorStops,
      tileMode: tileMode,
      startAngle: startAngle,
      endAngle: endAngle,
      matrix4: matrix4,
    );
  }
}
