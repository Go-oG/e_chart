import 'dart:ui' as ui;
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math.dart' as vm;

abstract class ChartShader {
  List<Color> colors;
  List<double>? colorStops;
  TileMode tileMode;
  Float64List? matrix4;

  ChartShader(
    this.colors, {
    this.colorStops,
    this.tileMode = TileMode.clamp,
    this.matrix4,
  });

  ui.Shader toShader(Rect rect);

  ChartShader lerp(covariant ChartShader begin, covariant ChartShader end, double animatorPercent);

  ChartShader convert(Set<ViewState>? states);

  Color? pickColor() {
    if (colors.isEmpty) {
      return null;
    }
    return colors.first;
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

  static List<double>? lerpDoubles(List<double>? begin, List<double>? end, double t) {
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
          double? sd;
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

  static Float64List? lerpMatrix4(Float64List? beginData, Float64List? endData, double t) {
    if (beginData == null && endData == null) {
      return null;
    }
    vm.Matrix4? begin;
    if (beginData != null) {
      begin = vm.Matrix4.fromList(beginData);
    }
    vm.Matrix4? end;
    if (endData != null) {
      end = vm.Matrix4.fromList(endData);
    }

    final Vector3 beginTranslation = Vector3.zero();
    final Vector3 endTranslation = Vector3.zero();

    final Quaternion beginRotation = Quaternion.identity();
    final Quaternion endRotation = Quaternion.identity();

    final Vector3 beginScale = Vector3.zero();
    final Vector3 endScale = Vector3.zero();
    if (begin != null) {
      begin.decompose(beginTranslation, beginRotation, beginScale);
    }
    if (end != null) {
      end.decompose(endTranslation, endRotation, endScale);
    }
    final Vector3 lerpTranslation = beginTranslation * (1.0 - t) + endTranslation * t;
    final Quaternion lerpRotation = (beginRotation.scaled(1.0 - t) + endRotation.scaled(t)).normalized();
    final Vector3 lerpScale = beginScale * (1.0 - t) + endScale * t;
    return Float64List.fromList(vm.Matrix4.compose(lerpTranslation, lerpRotation, lerpScale).storage);
  }
}
