import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/view_state.dart';
import 'shader.dart';

class LineShader extends ChartShader {
  /// 表示渐变的偏移量dx,dy取值范围从从[0,1]
  Offset from;
  Offset to;

  LineShader(
    super.colors, {
    this.from = const Offset(0, 0.5),
    this.to = const Offset(1, 0.5),
    super.colorStops,
    super.tileMode,
    super.matrix4,
  });

  @override
  ui.Shader toShader(Rect rect) {
    Offset fromOffSet;
    Offset toOffSet;
    fromOffSet = Offset(rect.left + from.dx * rect.width, rect.top + from.dy * rect.height);
    toOffSet = Offset(rect.left + to.dx * rect.width, rect.top + to.dy * rect.height);
    return ui.Gradient.linear(fromOffSet, toOffSet, colors, colorStops, tileMode, matrix4);
  }

  @override
  ChartShader lerp(covariant LineShader end, double t) {
    List<Color> colorList = ChartShader.lerpColors(colors, end.colors, t);
    List<double>? stepList = ChartShader.lerpDoubles(colorStops, end.colorStops, t);
    Float64List? ma = ChartShader.lerpMatrix4(matrix4, end.matrix4, t);

    return LineShader(
      from: Offset.lerp(from, end.from, t)!,
      to: Offset.lerp(to, end.to, t)!,
      colorList,
      colorStops: stepList,
      tileMode: tileMode == TileMode.clamp ? end.tileMode : tileMode,
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
    return LineShader(
      cl,
      from: from,
      to: to,
      colorStops: colorStops,
      tileMode: tileMode,
      matrix4: matrix4,
    );
  }
}
