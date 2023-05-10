import 'dart:math';
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
  final BoxShadow? shadow;
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
    this.shadow,
    this.shader,
    this.smooth = false,
    this.align = Align2.center,
  });

  void fillPaint(Paint paint, {Rect? rect, double? maxStrokeWidth, double? colorOP}) {
    paint.reset();
    paint.color = colorOP == null ? color : color.withOpacity(colorOP);
    paint.strokeCap = cap;
    paint.strokeJoin = join;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width;
    if (maxStrokeWidth != null && maxStrokeWidth > 0) {
      if (width > maxStrokeWidth) {
        paint.strokeWidth = maxStrokeWidth;
      }
    }

    if (shader != null && rect != null) {
      paint.shader = shader!.toShader(rect, colorOP);
    }
    if (shadow != null) {
      paint.color = shadow!.color;
      paint.maskFilter = MaskFilter.blur(shadow!.blurStyle, shadow!.blurSigma);
    }
  }

  void drawPolygon(
    Canvas canvas,
    Paint paint,
    List<Offset> points, {
    bool close = false,
    bool refillPaint = true,
    double? maxWidth,
  }) {
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
      return;
    }

    Line line = Line(points,smoothRatio:smooth ? 0.4 : null,dashList: dash );
    Path path = line.path(close);

    if (refillPaint) {
      Rect? rect;
      if (shader != null) {
        if (close) {
          rect = path.getBounds();
        } else {
          double left = double.infinity;
          double top = double.infinity;
          double right = double.negativeInfinity;
          double bottom = double.negativeInfinity;
          for (var element in points) {
            left = min(element.dx, left);
            right = max(element.dx, right);
            top = min(element.dy, top);
            bottom = max(element.dy, bottom);
          }
        }
      }
      fillPaint(paint, rect: rect, maxStrokeWidth: maxWidth);
    }

    if (shadow != null) {
      path.drawShadows(canvas, Paint(), path, [shadow!]);
    }
    canvas.drawPath(path, paint);
  }

  void drawPath(Canvas canvas, Paint paint, Path path, {bool drawDash = false, double? maxWidth, double? colorOP}) {
    if (shadow != null) {
      path.drawShadows(canvas, paint, path, [shadow!]);
    }
    fillPaint(paint, maxStrokeWidth: maxWidth, colorOP: colorOP);
    if (drawDash && dash.isNotEmpty) {
      canvas.drawPath(dashPath(path, dash), paint);
    } else {
      canvas.drawPath(path, paint);
    }
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
    if (shadow != null) {
      path.drawShadows(canvas, paint, path, [shadow!]);
    }
    fillPaint(paint, rect: path.getBounds());
    if (dash.isNotEmpty) {
      canvas.drawPath(dashPath(path, dash), paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }
}
