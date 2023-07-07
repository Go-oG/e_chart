import 'dart:ui';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'package:e_chart/src/ext/path_ext.dart';
import 'package:e_chart/src/shape/area.dart';
import 'package:flutter/material.dart';
import '../component/shader/shader.dart' as sd;

import '../core/view_state.dart';
import '../shape/line.dart';
import 'line_style.dart';

/// 区域样式
class AreaStyle {
  final bool show;

  ///控制是否是曲线
  final bool smooth;
  final Color? color;
  final sd.Shader? shader;
  final List<BoxShadow> shadow;
  final LineStyle? border;

  const AreaStyle({
    this.show = true,
    this.color,
    this.shader,
    this.shadow = const [],
    this.border,
    this.smooth = false,
  });

  @override
  String toString() {
    return '[AreaStyle:Color:$color shader:${shader.runtimeType} shadow:$shadow border:$border ]';
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

  void drawPolygonArea(Canvas canvas, Paint paint, List<Offset> points,[bool drawBorder=true]) {
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
    Line line = Line(points, smoothRatio: smooth ? 0.25 : null);
    drawPath(canvas, paint, line.toPath(true));
  }

  void drawArea(Canvas canvas, Paint paint, List<Offset> p1List, List<Offset> p2List,[bool drawBorder=true]) {
    if (_notDraw()) {
      return;
    }
    Area area = Area(p1List, p2List, upSmooth: smooth, downSmooth: smooth, ratioA: 0.25, ratioB: 0.25);
    drawPath(canvas, paint, area.toPath(true));
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, [double? corner, bool drawBorder = true]) {
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
    drawPath(canvas, paint, path);
  }

  void drawRRect(Canvas canvas, Paint paint, RRect rect, [bool drawBorder = true]) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    path.addRRect(rect);
    drawPath(canvas, paint, path);
  }

  void drawCircle(Canvas canvas, Paint paint, Offset center, num radius, [bool drawBorder = true]) {
    if (_notDraw()) {
      return;
    }
    Path path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius.toDouble()));
    drawPath(canvas, paint, path);
  }

  void drawPath(Canvas canvas, Paint paint, Path path, [bool drawBorder = true]) {
    if (_notDraw()) {
      return;
    }
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    fillPaint(paint, path.getBounds());
    canvas.drawPath(path, paint);
    if (drawBorder) {
      border?.drawPath(canvas, paint, path, true);
    }
  }

  AreaStyle convert(Set<ViewState>? states) {
    if (states == null || states.isEmpty) {
      return this;
    }
    final Color? color = this.color == null ? null : ColorResolver(this.color!).resolve(states);
    final sd.Shader? shader = this.shader == null ? null : this.shader!.convert2(states);
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
    final LineStyle? border = this.border == null ? null : this.border!.convert(states);
    return AreaStyle(show: show, smooth: smooth, shader: shader, shadow: shadow, border: border, color: color);
  }

  bool _notDraw() {
    if (color == null && shader == null && shadow.isEmpty && border == null) {
      return true;
    }
    return !show;
  }
}
