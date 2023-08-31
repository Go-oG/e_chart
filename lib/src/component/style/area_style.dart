import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 区域样式
class AreaStyle {
  static const AreaStyle empty = AreaStyle();

  final Color? color;
  final ChartShader? shader;
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
    if (notDraw) {
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
    if (notDraw) {
      return;
    }
    Area area = Area(p1List, p2List, upSmooth: smooth, downSmooth: smooth);
    drawPath(canvas, paint, area.toPath(true));
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, [Corner? corner]) {
    if (notDraw) {
      return;
    }
    Path path = Path();
    if (corner == null) {
      path.addRect(rect);
      path.close();
    } else {
      path.addRRect(rect.toRRect(corner));
      path.close();
    }
    drawPath(canvas, paint, path);
  }

  void drawRRect(Canvas canvas, Paint paint, RRect rect) {
    if (notDraw) {
      return;
    }
    Path path = Path();
    path.addRRect(rect);
    drawPath(canvas, paint, path);
  }

  void drawCircle(Canvas canvas, Paint paint, Offset center, num radius) {
    if (notDraw) {
      return;
    }
    Path path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius.toDouble()));
    drawPath(canvas, paint, path);
  }

  void drawPath(Canvas canvas, Paint paint, Path path) {
    if (notDraw) {
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
    final ChartShader? shader = this.shader == null ? null : this.shader!.convert(states);
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

  bool get notDraw {
    if (color == null && shader == null && shadow.isEmpty) {
      return true;
    }
    return false;
  }

  bool get canDraw {
    return !notDraw;
  }

  Color? pickColor() {
    if (shader != null) {
      return shader!.pickColor();
    }
    return color;
  }
}
