import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/platform_util.dart';

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

  void drawPolygonArea(Canvas canvas, Paint paint, List<Offset> points) {
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
    Polygon polygon = Polygon(points, true);
    drawPath(canvas, paint, polygon.toPath());
  }

  void drawArea(Canvas canvas, Paint paint, List<Offset> p1List, List<Offset> p2List, [num smooth = 0]) {
    if (notDraw) {
      return;
    }
    Area area = Area(p1List, p2List, upSmooth: smooth, downSmooth: smooth);
    drawPath(canvas, paint, area.toPath());
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

  void drawArc(Canvas canvas, Paint paint, Arc arc) {
    if (!isWeb) {
      drawPath(canvas, paint, arc.toPath());
      return;
    }

    if (arc.sweepAngle.abs() >= Arc.circleMinAngle) {
      if (arc.innerRadius <= 0) {
        drawCircle(canvas, paint, arc.center, arc.outRadius);
        return;
      }
      num r = (arc.outRadius - arc.innerRadius);
      LineStyle style = LineStyle(color: color, shader: shader, shadow: shadow, width: r);
      style.drawCircle(canvas, paint, arc.center, arc.outRadius - r / 2);
    } else {
      drawPath(canvas, paint, arc.toPath());
    }
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

  static AreaStyle? lerp(AreaStyle? start, AreaStyle? end, double t) {
    var c = Color.lerp(start?.color, end?.color, t);
    var ss = start?.shader;
    var es = end?.shader;
    var shader = ChartShader.lerpShader(ss, es, t);
    var shadow = BoxShadow.lerpList(start?.shadow, end?.shadow, t) ?? [];
    return AreaStyle(color: c, shader: shader, shadow: shadow);
  }
}
