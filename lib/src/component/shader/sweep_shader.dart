import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/view_state.dart';
import 'shader.dart';

class SweepShader extends ChartShader {
  final double startAngle;
  final double endAngle;

  const SweepShader(
    super.colors, {
    this.startAngle = 0,
    this.endAngle = 360,
    super.colorStops,
    super.tileMode = TileMode.clamp,
    super.matrix4,
  });

  @override
  int get hashCode {
    int sp = super.hashCode;
    return Object.hash(sp, startAngle, endAngle);
  }

  @override
  bool operator ==(Object other) {
    if (other is! SweepShader) {
      return false;
    }
    if (other.startAngle != startAngle || other.endAngle != endAngle) {
      return false;
    }
    return super == other;
  }

  @override
  ui.Shader toShader(Rect rect) {
    Offset center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
    double sa = pi * startAngle / 180.0;
    double ea = pi * endAngle / 180.0;
    return ui.Gradient.sweep(center, colors, colorStops, tileMode, sa, ea, matrix4);
  }

  @override
  ChartShader lerp(covariant SweepShader end, double t) {
    List<Color> colorList = ChartShader.lerpColors(colors, end.colors, t);
    List<double>? stepList = ChartShader.lerpDoubles(colorStops, end.colorStops, t);
    Float64List? ma = ChartShader.lerpMatrix4(matrix4, end.matrix4, t);
    return SweepShader(
      colorList,
      colorStops: stepList,
      tileMode: tileMode == TileMode.clamp ? end.tileMode : tileMode,
      startAngle: lerpDouble(startAngle, end.startAngle, t)!,
      endAngle: lerpDouble(endAngle, end.endAngle, t)!,
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
