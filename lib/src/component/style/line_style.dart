import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../shader/shader.dart' as sd;

/// 线段样式
class LineStyle {
  static const LineStyle empty = LineStyle(width: 0);
  final Color? color;
  final num width;
  final StrokeCap cap;
  final StrokeJoin join;
  final List<num> dash;
  final List<BoxShadow> shadow;
  final sd.ChartShader? shader;
  final num smooth;

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
    this.smooth = 0,
    this.align = Align2.center,
  });

  @override
  int get hashCode {
    return Object.hashAll(
        [color, width, cap, join, Object.hashAll(dash), Object.hashAll(shadow), shader, smooth, align]);
  }

  @override
  bool operator ==(Object other) {
    if(other is! LineStyle){
      return false;
    }
    if(other.color!=color){return false;}
    if(other.width!=width){return false;}
    if(other.cap!=cap){return false;}
    if(other.join!=join){return false;}
    if(!listEquals(other.dash, dash)){
      return false;
    }
    if(!listEquals(other.shadow, shadow)){return false;}
    if(other.shader!=shader){return false;}
    if(other.smooth!=smooth){return false;}
    return other.align==align;

  }

  Color? pickColor() {
    if (shader != null) {
      return shader!.pickColor();
    }
    return color;
  }

  void fillPaint(Paint paint, [Rect? rect]) {
    paint.reset();
    if (color != null) {
      paint.color = color!;
    }
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
    if (width <= 0) {
      return;
    }
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
      return;
    }

    Path path = Line(points, smooth: 0, dashList: dash).toPath();
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

      if (smooth <= 0 && dash.isEmpty) {
        canvas.drawPoints(PointMode.polygon, ol, paint);
        continue;
      }

      Line line = Line(ol, smooth: smooth, dashList: dash);
      Path p = line.toPath();
      canvas.drawPath(p, paint);
    }
  }

  ///绘制一个圆弧部分(也可以绘制圆)
  void drawArc(Canvas canvas, Paint paint, num radius, num startAngle, num sweepAngle, [Offset center = Offset.zero]) {
    if (width <= 0) {
      return;
    }
    //优化绘制半径、消除
    double r = radius.toDouble();
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

  void drawCircle(Canvas canvas, Paint paint, Offset center, num radius) {
    var rect = Rect.fromCircle(center: center, radius: radius.toDouble());
    fillPaint(paint, rect);
    canvas.drawCircle(center, radius.toDouble(), paint);
  }

  void drawRect(Canvas canvas, Paint paint, Rect rect, [Corner? corner]) {
    if (width <= 0) {
      return;
    }
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
  void drawPath(Canvas canvas, Paint paint, Path path,
      {bool drawDash = false, bool needSplit = true, num splitLength = 200}) {
    if (width <= 0) {
      return;
    }
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
    var c = this.color;
    if (c == null) {
      return this;
    }

    final Color color = ColorResolver(c).resolve(states)!;

    final sd.ChartShader? shader = this.shader == null ? null : this.shader!.convert(states);

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

  bool get notDraw => width <= 0;

  bool get canDraw => width > 0;

  static LineStyle lerp(LineStyle? start, LineStyle? end, double t) {
    if (start == null && end == null) {
      return LineStyle.empty;
    }
    var c = Color.lerp(start?.color, end?.color, t);
    var ss = start?.shader;
    var es = end?.shader;
    var shader = ChartShader.lerpShader(ss, es, t);
    var shadow = BoxShadow.lerpList(start?.shadow, end?.shadow, t) ?? [];
    var w = lerpDouble(start?.width, end?.width, t)!;
    if (w <= 0) {
      return LineStyle.empty;
    }

    return LineStyle(
      color: c,
      shader: shader,
      shadow: shadow,
      width: w,
      dash: ChartShader.lerpDoubles(start?.dash, end?.dash, t) ?? [],
      smooth: lerpDouble(start?.smooth, end?.smooth, t)!,
      cap: (end?.cap ?? start?.cap)!,
      join: (end?.join ?? start?.join)!,
      align: (end?.align ?? start?.align)!,
    );
  }
}
