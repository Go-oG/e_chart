import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../shader/shader.dart' as sd;

/// 线段样式
class LineStyle {
  final Color color;
  final num width;
  final StrokeCap cap;
  final StrokeJoin join;
  final List<num> dash;
  final List<BoxShadow> shadow;
  final sd.ChartShader? shader;
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
    this.shadow = const [],
    this.shader,
    this.smooth = false,
    this.align = Align2.center,
  });

  void fillPaint(Paint paint, [Rect? rect]) {
    paint.reset();
    paint.color = color;
    paint.strokeCap = cap;
    paint.strokeJoin = join;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width.toDouble();
    if (shader != null && rect != null) {
      paint.shader = shader!.toShader(rect);
    }
  }

  ///绘制多边形(或者线段)
  ///下方这样写是为了改善Flutter上Path过长时
  ///绘制效率低下的问题
  void drawPolygon(Canvas canvas, Paint paint, List<Offset> points, [bool close = false]) {
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
      return;
    }

    Path path = Line(points, smooth: false, dashList: dash).toPath(close);
    fillPaint(paint, path.getBounds());

    List<List<Offset>> olList = [];
    List<Offset> tmpList = [];
    for (int i = 0; i < points.length; i++) {
      if (tmpList.isEmpty && i != 0) {
        tmpList.add(points[i - 1]);
      }
      tmpList.add(points[i]);
      if (tmpList.length >= 30) {
        olList.add(tmpList);
        tmpList = [];
      }
    }
    if (tmpList.isNotEmpty) {
      olList.add(tmpList);
    }
    if (close) {
      olList.last.add(points.first);
    }

    for (var ol in olList) {
      if (ol.length == 1) {
        canvas.drawPoints(PointMode.points, ol, paint);
        continue;
      }

      if (!smooth && dash.isEmpty) {
        canvas.drawPoints(PointMode.polygon, ol, paint);
        continue;
      }

      Line line = Line(ol, smooth: smooth, dashList: dash);
      Path p = line.toPath(false);
      canvas.drawPath(p, paint);
    }
  }

  ///绘制一个圆弧部分(也可以绘制圆)
  void drawArc(Canvas canvas, Paint paint, double radius, num startAngle, num sweepAngle,
      [Offset center = Offset.zero]) {
    //优化绘制半径、消除
    double r = radius;
    if (align == Align2.start) {
      r -= width / 2;
    } else if (align == Align2.end) {
      r += width / 2;
    }
    Arc arc = Arc(outRadius: r, startAngle: startAngle, sweepAngle: sweepAngle, center: center);
    Path path = arc.arcOpen();
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    Rect? rect;
    if (shader != null) {
      rect = Rect.fromCircle(center: center, radius: r);
    }
    fillPaint(paint, rect);
    if (dash.isNotEmpty) {
      path = path.dashPath(dash);
    }
    canvas.drawPath(path, paint);
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, [Corner? corner]) {
    RRect? rRect;
    if (corner != null) {
      var lt = Radius.circular(corner.leftTop);
      var rt = Radius.circular(corner.rightTop);
      var lb = Radius.circular(corner.leftBottom);
      var rb = Radius.circular(corner.rightBottom);
      rRect = RRect.fromRectAndCorners(rect, topLeft: lt, topRight: rt, bottomLeft: lb, bottomRight: rb);
    }
    Rect? shaderRect;
    if (shader != null) {
      shaderRect = rect;
    }
    fillPaint(paint, shaderRect);
    if (shadow.isNotEmpty || dash.isNotEmpty) {
      Path path = Path();
      if (rRect != null) {
        path.addRRect(rRect);
      } else {
        path.addRect(rect);
      }
      if (shadow.isNotEmpty) {
        path.drawShadows(canvas, path, shadow);
      }
      if (dash.isNotEmpty) {
        path = path.dashPath(dash);
      }
      canvas.drawPath(path, paint);
      return;
    }
    if (rRect != null) {
      canvas.drawRRect(rRect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  ///请注意该方法在Path 路径过长时会出现
  ///此时应该将needSplit 指定为true进行优化
  ///绘制效率严重低下的问题
  void drawPath(Canvas canvas, Paint paint, Path path, {bool drawDash = false, bool needSplit = true,num splitLength=200}) {
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    Rect? rect;
    if (shader != null) {
      rect = path.getBounds();
    }
    fillPaint(paint, rect);

    if (drawDash && dash.isNotEmpty) {
      path = path.dashPath(dash);
    }
    if (!needSplit) {
      canvas.drawPath(path, paint);
      return;
    }

    for (var p in path.split(splitLength)) {
      canvas.drawPath(p, paint);
    }
  }

  LineStyle convert(Set<ViewState>? states) {
    if (states == null || states.isEmpty) {
      return this;
    }

    final Color color = ColorResolver(this.color).resolve(states)!;

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

    return LineStyle(
      color: color,
      width: width,
      cap: cap,
      join: join,
      dash: dash,
      smooth: smooth,
      shader: shader,
      shadow: shadow,
    );
  }
}
