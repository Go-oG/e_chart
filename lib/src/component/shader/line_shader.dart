import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import '../../core/view_state.dart';
import 'shader.dart';

class LineShader extends Shader {
  /// 表示渐变的偏移量dx,dy取值范围从从[0,1]
  final Offset from;
  final Offset to;
  final List<Color> colors;
  final List<double>? colorStops;
  final TileMode tileMode;
  final Float64List? matrix4;

  const LineShader(
    this.colors, {
    this.from = const Offset(0, 0.5),
    this.to = const Offset(1, 0.5),
    this.colorStops,
    this.tileMode = TileMode.clamp,
    this.matrix4,
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
  Shader convert(covariant LineShader begin, covariant LineShader end, double animatorPercent) {
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

    return LineShader(
      from: Offset.lerp(begin.from, end.from, animatorPercent)!,
      to: Offset.lerp(begin.to, end.to, animatorPercent)!,
      colorList,
      colorStops: colorStopsList,
      tileMode: begin.tileMode == TileMode.clamp ? end.tileMode : begin.tileMode,
      matrix4: ma,
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
