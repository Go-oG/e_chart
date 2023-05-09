import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:xchart/src/component/shader/shader.dart' as sd;
import 'package:xchart/src/ext/paint_ext.dart';
import 'package:xchart/src/ext/path_ext.dart';
import '../shape/line.dart';
import 'line_style.dart';

/// 区域样式
class AreaStyle {
  final bool show;
  final Color? color;
  final sd.Shader? shader;
  final BoxShadow? shadow;
  final LineStyle? border;

  const AreaStyle({this.show = true, this.color, this.shader, this.shadow, this.border});

  @override
  String toString() {
    return '[AreaStyle:Color:$color shader:${shader.runtimeType} shadow:$shadow border:$border ]';
  }

  void fillPaint(Paint paint, Rect? rect, {double? colorOpacity}) {
    paint.reset();
    if (color != null) {
      if (colorOpacity != null) {
        paint.color = color!.withOpacity(colorOpacity);
      } else {
        paint.color = color!;
      }
    }
    if (shader != null && rect != null) {
      paint.shader = shader!.toShader(rect, colorOpacity);
    }
  }

  void drawPath(Canvas canvas, Paint paint, Path path, {double? colorOpacity, bool drawDash = false}) {
    if (_notDraw()) {
      return;
    }
    fillPaint(paint, path.getBounds(), colorOpacity: colorOpacity);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    border?.drawPath(canvas, paint, path, drawDash: drawDash, colorOP: colorOpacity);

    if (shadow != null) {
      path.drawShadows(canvas, paint, path, [shadow!]);
    }
  }

  void drawPolygonArea(Canvas canvas, Paint paint, List<Offset> points, {double? colorOpacity}) {
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

    Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      Offset offset = points[i];
      path.lineTo(offset.dx, offset.dy);
    }
    if (points.length >= 3) {
      path.close();
    }
    fillPaint(paint, path.getBounds(), colorOpacity: colorOpacity);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    border?.drawPolygon(canvas, paint, points, close: true);
  }

  void drawArea(Canvas canvas, Paint paint, List<Offset> p1List, List<Offset> p2List, bool first) {
    if (_notDraw()) {
      return;
    }
    Path path;
    bool smooth = border != null && border!.smooth;
    if (first) {
      Line line = Line(p1List, smoothRatio: smooth ? 0.2 : null);
      path = line.path(false);
      for (int i = p2List.length - 1; i >= 0; i--) {
        var element = p2List[i];
        path.lineTo(element.dx, element.dy);
      }
      path.close();
    } else {
      if (smooth) {
        path = Line.smoothArea(p1List, p2List, ratio: 0.2);
      } else {
        Line line = Line(p1List);
        path = line.path(false);
        for (int i = p2List.length - 1; i >= 0; i--) {
          var element = p2List[i];
          path.lineTo(element.dx, element.dy);
        }
        path.close();
      }
    }

    fillPaint(paint, path.getBounds());
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    List<Offset> list = [...p1List];
    list.addAll(p2List.reversed);
    border?.drawPolygon(canvas, paint, list, close: true);
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, {double? colorOpacity, double? corner}) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    if (corner == null || corner <= 0) {
      path.addRect(rect);
      path.close();
    } else {
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(corner)));
      path.close();
    }
    drawPath(canvas, paint, path, drawDash: true, colorOpacity: colorOpacity);
  }

  void drawRRect(Canvas canvas, Paint paint, RRect rect, {double? colorOpacity}) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    path.addRRect(rect);
    drawPath(canvas, paint, path, colorOpacity: colorOpacity, drawDash: true);
  }

  void drawPath2(Canvas canvas, Paint paint, Path p1, Path? p2) {
    if (_notDraw()) {
      return;
    }
    Path path = p1;
    if (p2 != null) {
      path = Path.combine(PathOperation.difference, p1, p2);
    }
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    border?.drawPath(canvas, paint, p1, drawDash: true);
    if (shadow != null) {
      path.drawShadows(canvas, paint, p1, [shadow!]);
    }
  }

  bool _notDraw() {
    if (color == null && shader == null && shadow == null && border == null) {
      return true;
    }
    return !show;
  }
}
