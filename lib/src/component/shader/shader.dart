import 'dart:ui' as ui;
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;

abstract class ChartShader {
  final List<Color> colors;
  final List<double>? colorStops;
  final TileMode tileMode;
  final ShaderTransform? transform;

  const ChartShader(
    this.colors, {
    this.colorStops,
    this.tileMode = TileMode.clamp,
    this.transform,
  });

  @override
  int get hashCode {
    var h = colorStops == null ? 2011 : Object.hashAll(colorStops!);
    return Object.hash(Object.hashAll(colors), h, tileMode, transform);
  }

  @override
  bool operator ==(Object other) {
    if (other is! ChartShader) {
      return false;
    }
    if (!listEquals(other.colors, colors)) {
      return false;
    }
    if (!listEquals(colorStops, other.colorStops)) {
      return false;
    }
    return other.tileMode == tileMode && other.transform == transform;
  }

  ui.Shader toShader(Rect rect);

  ChartShader lerp(covariant ChartShader end, double t);

  ChartShader convert(Set<ViewState>? states);

  Color? pickColor() {
    if (colors.isEmpty) {
      return null;
    }
    return colors.first;
  }

  Float64List? resolveTransform(Rect bounds) {
    return transform?.transform(bounds)?.storage;
  }

  static List<Color> lerpColors(List<Color> begin, List<Color> end, double t) {
    List<Color> colorList = [];
    if (begin.length == end.length) {
      for (int i = 0; i < begin.length; i++) {
        colorList.add(Color.lerp(begin[i], end[i], t)!);
      }
    } else {
      each(end, (color, i) {
        Color? sc;
        if (i < begin.length) {
          sc = begin[i];
        }
        colorList.add(Color.lerp(sc, color, t)!);
      });
    }
    return colorList;
  }

  static List<double>? lerpDoubles(List<num>? begin, List<num>? end, double t) {
    if (begin == null && end == null) {
      return null;
    }
    if (begin != null && end != null) {
      List<double> stepList = [];
      if (begin.length == end.length) {
        for (int i = 0; i < begin.length; i++) {
          stepList.add(lerpDouble(begin[i], end[i], t)!);
        }
      } else {
        each(end, (value, i) {
          num? sd;
          if (i < begin.length) {
            sd = begin[i];
          }
          stepList.add(lerpDouble(sd, value, t)!);
        });
      }
      return stepList;
    }
    if (end != null) {
      List<double> stepList = [];
      each(end, (value, i) {
        stepList.add(lerpDouble(null, value, t)!);
      });
      return stepList;
    }
    List<double> stepList = [];
    each(begin!, (value, i) {
      stepList.add(lerpDouble(value, null, t)!);
    });
    return stepList;
  }

  static ChartShader? lerpShader(ChartShader? start, ChartShader? end, double t) {
    if (start == null && end == null) {
      return null;
    }
    if (start != null && end != null) {
      if (start.runtimeType == end.runtimeType) {
        return start.lerp(end, t);
      }
      if (t < 0.5) {
        return _lerpShader2(start, t, true);
      } else {
        return _lerpShader2(end, t, false);
      }
    }

    if (end != null) {
      return _lerpShader2(end, t, false);
    }
    return _lerpShader2(start!, t, true);
  }

  static ChartShader _lerpShader2(ChartShader shader, double t, bool from) {
    var cc = const ui.Color(0x00000000);
    List<Color> cl = List.filled(shader.colors.length, cc);
    List<Color> colorList;
    if (from) {
      colorList = lerpColors(shader.colors, cl, t);
    } else {
      colorList = lerpColors(cl, shader.colors, t);
    }
    if (shader is LineShader) {
      return LineShader(
        colorList,
        from: shader.from,
        to: shader.to,
        colorStops: shader.colorStops,
        tileMode: shader.tileMode,
        transform: shader.transform,
      );
    }
    if (shader is SweepShader) {
      return SweepShader(
        colorList,
        startAngle: shader.startAngle,
        endAngle: shader.endAngle,
        colorStops: shader.colorStops,
        tileMode: shader.tileMode,
        transform: shader.transform,
      );
    }
    if (shader is RadialShader) {
      return RadialShader(
        colorList,
        focal: shader.focal,
        focalRadius: shader.focalRadius,
        colorStops: shader.colorStops,
        tileMode: shader.tileMode,
        transform: shader.transform,
      );
    }
    throw ChartError("Not Support");
  }
}

abstract class ShaderTransform {
  const ShaderTransform();

  vm64.Matrix4? transform(Rect bounds);
}
