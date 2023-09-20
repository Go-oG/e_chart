import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../core/index.dart';
import 'shader.dart';

class LineShader extends ChartShader {
  /// 表示渐变的偏移量dx,dy取值范围从从[0,1]
  final Alignment from;
  final Alignment to;

  const LineShader(
    super.colors, {
    this.from = Alignment.centerLeft,
    this.to = Alignment.centerRight,
    super.colorStops,
    super.tileMode,
    super.transform,
  });

  @override
  int get hashCode {
    int sp = super.hashCode;
    return Object.hash(sp, from, to);
  }

  @override
  bool operator ==(Object other) {
    if (other is! LineShader) {
      return false;
    }
    if (other.from != from || other.to != to) {
      return false;
    }
    return super == other;
  }

  @override
  ui.Shader toShader(Rect rect) {
    return ui.Gradient.linear(
      from.withinRect(rect),
      to.withinRect(rect),
      colors,
      colorStops,
      tileMode,
      resolveTransform(rect),
    );
  }

  @override
  ChartShader lerp(covariant LineShader end, double t) {
    List<Color> colorList = ChartShader.lerpColors(colors, end.colors, t);
    List<double>? stepList = ChartShader.lerpDoubles(colorStops, end.colorStops, t);
    return LineShader(
      from: Alignment.lerp(from, end.from, t)!,
      to: Alignment.lerp(to, end.to, t)!,
      colorList,
      colorStops: stepList,
      tileMode: t < 0.5 ? tileMode : end.tileMode,
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
    return LineShader(
      cl,
      from: from,
      to: to,
      colorStops: colorStops,
      tileMode: tileMode,
      transform: transform,
    );
  }
}
