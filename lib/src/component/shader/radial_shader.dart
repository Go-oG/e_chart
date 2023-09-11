import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/view_state.dart';
import 'shader.dart';

class RadialShader extends ChartShader {
  final Alignment center;
  final Alignment? focal;

  ///[0,1]
  final double focalRadius;

  const RadialShader(
    super.colors, {
    this.center = Alignment.center,
    super.colorStops,
    super.tileMode = ui.TileMode.clamp,
    super.transform,
    this.focal,
    this.focalRadius = 0.0,
  });

  @override
  int get hashCode {
    int sp = super.hashCode;
    return Object.hash(sp, focal, focalRadius);
  }

  @override
  bool operator ==(Object other) {
    if (other is! RadialShader) {
      return false;
    }
    if (other.focal != focal || other.focalRadius != focalRadius) {
      return false;
    }
    return super == other;
  }

  @override
  ui.Shader toShader(Rect rect) {
    double radius = max(rect.width, rect.height) * 0.5;
    return ui.Gradient.radial(
      center.withinRect(rect),
      radius,
      colors,
      colorStops,
      tileMode,
      resolveTransform(rect),
      focal == null ? null : focal!.withinRect(rect),
      focalRadius * rect.shortestSide,
    );
  }

  @override
  ChartShader lerp(covariant RadialShader end, double t) {
    List<Color> colorList = ChartShader.lerpColors(colors, end.colors, t);
    List<double>? stepList = ChartShader.lerpDoubles(colorStops, end.colorStops, t);
    return RadialShader(
      colorList,
      colorStops: stepList,
      tileMode: t >= 0.5 ? end.tileMode : tileMode,
      transform: t < 0.5 ? transform : end.transform,
      focal: Alignment.lerp(focal, end.focal, t),
      focalRadius: lerpDouble(focalRadius, end.focalRadius, t)!,
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
    return RadialShader(
      cl,
      colorStops: colorStops,
      tileMode: tileMode,
      focal: focal,
      focalRadius: focalRadius,
      transform: transform,
    );
  }
}
