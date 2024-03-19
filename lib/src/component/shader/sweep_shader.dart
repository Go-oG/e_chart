import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../../core/helper/state_resolver.dart';

class SweepShader extends ChartShader {
  final Alignment center;
  final double startAngle;
  final double endAngle;

  const SweepShader(
    super.colors, {
    this.center = Alignment.center,
    this.startAngle = 0,
    this.endAngle = 360,
    super.colorStops,
    super.tileMode = TileMode.clamp,
    super.transform,
  });

  @override
  int get hashCode {
    int sp = super.hashCode;
    return Object.hash(sp, startAngle, endAngle, center);
  }

  @override
  bool operator ==(Object other) {
    if (other is! SweepShader) {
      return false;
    }
    if (other.startAngle != startAngle || other.endAngle != endAngle || other.center != center) {
      return false;
    }
    return super == other;
  }

  @override
  ui.Shader toShader(Rect rect) {
    double sa = pi * startAngle / 180.0;
    double ea = pi * endAngle / 180.0;
    var c = center.withinRect(rect);
    return ui.Gradient.sweep(c, colors, colorStops, tileMode, sa, ea, resolveTransform(rect));
  }

  @override
  ChartShader lerp(covariant SweepShader end, double t) {
    List<Color> colorList = ChartShader.lerpColors(colors, end.colors, t);
    List<double>? stepList = ChartShader.lerpDoubles(colorStops, end.colorStops, t);
    return SweepShader(
      colorList,
      colorStops: stepList,
      tileMode: t < 0.5 ? tileMode : end.tileMode,
      startAngle: lerpDouble(startAngle, end.startAngle, t)!,
      endAngle: lerpDouble(endAngle, end.endAngle, t)!,
      transform: t < 0.5 ? transform : end.transform,
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
      transform: transform,
    );
  }
}
