import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/view_state.dart';
import 'shader.dart';

class RadialShader extends ChartShader {
  Offset? focal;
  double focalRadius;

  RadialShader(
    super.colors, {
    super.colorStops,
    super.tileMode = ui.TileMode.clamp,
    super.matrix4,
    this.focal,
    this.focalRadius = 0.0,
  });

  @override
  ui.Shader toShader(Rect rect) {
    Offset center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
    double radius = max(rect.width, rect.height) * 0.5;
    return ui.Gradient.radial(center, radius, colors, colorStops, tileMode, matrix4, focal, focalRadius);
  }

  @override
  ChartShader lerp( covariant RadialShader end, double t) {
    List<Color> colorList = ChartShader.lerpColors(colors, end.colors, t);
    List<double>? stepList = ChartShader.lerpDoubles(colorStops, end.colorStops, t);
    Float64List? ma = ChartShader.lerpMatrix4(matrix4, end.matrix4, t);

    return RadialShader(
      colorList,
      colorStops: stepList,
      tileMode: tileMode == TileMode.clamp ? end.tileMode : tileMode,
      matrix4: ma,
      focal: Offset.lerp(focal, end.focal, t),
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
      matrix4: matrix4,
    );
  }
}
