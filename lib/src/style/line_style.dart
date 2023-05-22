import 'dart:ui';
import 'package:flutter/material.dart';
import '../component/shader/shader.dart' as sd;
import '../ext/paint_ext.dart';
import '../ext/path_ext.dart';

import '../model/enums/align2.dart';
import '../shape/arc.dart';
import '../shape/line.dart';

/// 线段样式
class LineStyle {
  final Color color;
  final double width;
  final StrokeCap cap;
  final StrokeJoin join;
  final List<double> dash;
  final List<BoxShadow> shadow;
  final sd.Shader? shader;
  final bool smooth;

  ///因为Flutter绘制直线时是平分的，
  ///因此为了优化视觉效果，提供了一个对齐方式
  final Align2 align;

  const LineStyle({
    this.color = Colors.black,
    this.width = 1,
    this.cap = StrokeCap.butt,
    this.join = StrokeJoin.miter,
    this.dash = const [],
    this.shadow=const [],
    this.shader,
    this.smooth = false,
    this.align = Align2.center,
  });

  void fillPaint(Paint paint, {Rect? rect}) {
    paint.reset();
    paint.color = color;
    paint.strokeCap = cap;
    paint.strokeJoin = join;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width;
    if (shader != null && rect != null) {
      paint.shader = shader!.toShader(rect, null);
    }
  }

  ///绘制多边形(或者线段)
  void drawPolygon(Canvas canvas, Paint paint, List<Offset> points, [bool close = false]) {
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
      return;
    }
    Line line = Line(points, smoothRatio: smooth ? 0.4 : null, dashList: dash);
    Path path = line.toPath(close);
    drawPath(canvas, paint, path);
  }

  ///绘制一个圆弧部分(也可以绘制圆)
  void drawArc(
    Canvas canvas,
    Paint paint,
    double radius,
    num startAngle,
    num sweepAngle, {
    Offset center = Offset.zero,
  }) {
    //优化绘制半径、消除
    double r = radius;
    if (align == Align2.start) {
      r -= width / 2;
    } else if (align == Align2.end) {
      r += width / 2;
    }
    Arc arc = Arc(outRadius: r, startAngle: startAngle, sweepAngle: sweepAngle, center: center);
    Path path = arc.arcOpen();
    drawPath(canvas, paint, path, drawDash: true);
  }

  void drawPath(Canvas canvas, Paint paint, Path path, {bool drawDash = false}) {
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }

    Rect? rect;
    if (shader != null) {
      rect = path.getBounds();
    }
    fillPaint(paint, rect: rect);
    if (drawDash && dash.isNotEmpty) {
      canvas.drawPath(dashPath(path, dash), paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }
}
