import 'dart:ui';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'package:e_chart/src/ext/path_ext.dart';
import 'package:e_chart/src/model/corner.dart';
import 'package:e_chart/src/shape/area.dart';
import 'package:flutter/material.dart';
import '../component/shader/shader.dart' as sd;

import '../core/view_state.dart';
import '../shape/line.dart';

/// 区域样式
class AreaStyle {
  final Color? color;
  final sd.ChartShader? shader;
  final List<BoxShadow> shadow;

  const AreaStyle({
    this.color,
    this.shader,
    this.shadow = const [],
  });

  @override
  String toString() {
    return '[AreaStyle:Color:$color shader:${shader.runtimeType} shadow:$shadow]';
  }

  void fillPaint(Paint paint, Rect? rect) {
    paint.reset();
    if (color != null) {
      paint.color = color!;
    }
    if (shader != null && rect != null) {
      paint.shader = shader!.toShader(rect);
    }
    paint.style = PaintingStyle.fill;
  }

  void drawPolygonArea(Canvas canvas, Paint paint, List<Offset> points, [bool smooth = false]) {
    if (_notDraw()) {
      return;
    }
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      fillPaint(paint, null);
      canvas.drawPoints(PointMode.points, points, paint);
      return;
    }
    Line line = Line(points, smooth: smooth);
    drawPath(canvas, paint, line.toPath(true));
  }

  void drawArea(Canvas canvas, Paint paint, List<Offset> p1List, List<Offset> p2List, [bool smooth = false]) {
    if (_notDraw()) {
      return;
    }
    Area area = Area(p1List, p2List, upSmooth: smooth, downSmooth: smooth);
    drawPath(canvas, paint, area.toPath(true));
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, [Corner? corner]) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    if (corner == null) {
      path.addRect(rect);
      path.close();
    } else {
      var lt = Radius.circular(corner.leftTop);
      var rt = Radius.circular(corner.rightTop);
      var lb = Radius.circular(corner.leftBottom);
      var rb = Radius.circular(corner.rightBottom);
      var r = RRect.fromRectAndCorners(
        rect,
        topLeft: lt,
        topRight: rt,
        bottomLeft: lb,
        bottomRight: rb,
      );
      path.addRRect(r);
      path.close();
    }
    drawPath(canvas, paint, path);
  }

  void drawRRect(Canvas canvas, Paint paint, RRect rect) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    path.addRRect(rect);
    drawPath(canvas, paint, path);
  }

  void drawCircle(Canvas canvas, Paint paint, Offset center, num radius) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius.toDouble()));
    drawPath(canvas, paint, path);
  }

  void drawPath(Canvas canvas, Paint paint, Path path) {
    if (_notDraw()) {
      return;
    }
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    fillPaint(paint, path.getBounds());
    canvas.drawPath(path, paint);
  }

  AreaStyle convert(Set<ViewState>? states) {
    if (states == null || states.isEmpty) {
      return this;
    }
    final Color? color = this.color == null ? null : ColorResolver(this.color!).resolve(states);
    final sd.ChartShader? shader = this.shader == null ? null : this.shader!.convert2(states);
    final List<BoxShadow> shadow = [];
    for (var bs in this.shadow) {
      shadow.add(BoxShadow(
        color: ColorResolver(bs.color).resolve(states)!,
        offset: bs.offset,
        blurRadius: bs.blurRadius,
        spreadRadius: bs.spreadRadius,
        blurStyle: bs.blurStyle,
      ));
    }

    return AreaStyle(shader: shader, shadow: shadow, color: color);
  }

  bool _notDraw() {
    if (color == null && shader == null && shadow.isEmpty) {
      return true;
    }
    return false;
  }
}
