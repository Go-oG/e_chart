import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import '../../core/view_state.dart';
import 'shader.dart';

class RadialShader extends Shader {
  List<Color> colors;
  List<double>? colorStops;
  TileMode tileMode; //= TileMode.clamp,
  Float64List? matrix4;
  Offset? focal;
  double focalRadius;

  RadialShader(
    this.colors, {
    this.colorStops,
    this.tileMode = ui.TileMode.clamp,
    this.matrix4,
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
  Shader convert(covariant RadialShader begin, covariant RadialShader end, double animatorPercent) {
    List<Color> colorList = [];
    if (begin.colors.length == end.colors.length) {
      for (int i = 0; i < begin.colors.length; i++) {
        colorList.add(Color.lerp(begin.colors[i], end.colors[i], animatorPercent)!);
      }
    } else {
      colorList = animatorPercent < 0.5 ? begin.colors : end.colors;
    }
    List<double>? colorStopsList;
    if (begin.colorStops != null && end.colorStops != null && (begin.colorStops!.length == end.colorStops!.length)) {
      colorStopsList = [];
      for (int i = 0; i < begin.colors.length; i++) {
        colorStopsList.add(lerpDouble(begin.colorStops![i], end.colorStops![i], animatorPercent)!);
      }
    } else {
      colorStopsList = animatorPercent < 0.5 ? begin.colorStops : end.colorStops;
    }

    Float64List? ma;
    if (begin.matrix4 != null && end.matrix4 != null && begin.matrix4!.length == end.matrix4!.length) {
      List<double> bl = begin.matrix4!.toList();
      List<double> el = end.matrix4!.toList();
      List<double> list = [];
      for (int i = 0; i < bl.length; i++) {
        list.add(lerpDouble(bl[i], el[i], animatorPercent)!);
      }
      ma = Float64List.fromList(list);
    } else {
      ma = begin.matrix4 ?? end.matrix4;
    }

    return RadialShader(
      colorList,
      colorStops: colorStopsList,
      tileMode: begin.tileMode == TileMode.clamp ? end.tileMode : begin.tileMode,
      matrix4: ma,
      focal: Offset.lerp(begin.focal, end.focal, animatorPercent),
      focalRadius: lerpDouble(begin.focalRadius, end.focalRadius, animatorPercent)!,
    );
  }

  @override
  Shader convert2(Set<ViewState>? states) {
    if (states == null || states.isEmpty) {
      return this;
    }
    List<Color> cl = [];
    for (var c in colors) {
      cl.add(ColorResolver(c).resolve(states)!);
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
