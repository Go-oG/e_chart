import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/platform_util.dart';

/// 区域样式(所有的绘制都是填充)
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
  int get hashCode {
    return Object.hashAll([color, shader, shadow]);
  }

  @override
  bool operator ==(Object other) {
    if (other is! AreaStyle) {
      return false;
    }
    return other.color == color && other.shader == shader && listEquals(other.shadow, shadow);
  }

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
    paint.strokeWidth = 0;
  }

  void drawPolygonArea(CCanvas canvas, Paint paint, List<Offset> points) {
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

    Path path = Path();
    each(points, (p0, i) {
      if (i == 0) {
        path.moveTo(p0.dx, p0.dy);
      } else {
        path.lineTo(p0.dx, p0.dy);
      }
    });
    drawPath(canvas, paint, path);
  }

  void drawPolygon(CCanvas canvas, Paint paint, Polygon polygon) {
    if (notDraw) {
      return;
    }
    if (polygon.points.isEmpty) {
      return;
    }
    if (polygon.points.length == 1) {
      fillPaint(paint, null);
      canvas.drawPoints(PointMode.points, polygon.points, paint);
      return;
    }
    drawPath(canvas, paint, polygon.toPath());
  }

  void drawRect(CCanvas canvas, Paint paint, Rect rect, [Corner? corner]) {
    if (notDraw) {
      return;
    }
    Path? path;
    if (shadow.isNotEmpty) {
      path = Path();
      if (corner == null) {
        path.addRect(rect);
        path.close();
      } else {
        path.addRRect(rect.toRRect(corner));
        path.close();
      }
      drawPath(canvas, paint, path, rect);
      return;
    }
    fillPaint(paint, rect);
    if (corner == null || corner.isEmpty) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(rect.toRRect(corner), paint);
    }
  }

  void drawRRect(CCanvas canvas, Paint paint, RRect rect) {
    if (notDraw) {
      return;
    }
    if (shadow.isNotEmpty) {
      Path path = Path();
      path.addRRect(rect);
      drawPath(canvas, paint, path, rect.outerRect);
      return;
    }
    fillPaint(paint, shader == null ? null : rect.outerRect);
    canvas.drawRRect(rect, paint);
  }

  void drawCircle(CCanvas canvas, Paint paint, Offset center, num radius) {
    if (notDraw) {
      return;
    }
    if (shader != null || shadow.isNotEmpty) {
      var rect = Rect.fromCircle(center: center, radius: radius.toDouble());
      Path path = Path();
      path.moveTo2(circlePoint(radius, 0, center));
      path.arcTo(rect, 0, 2 * pi - 0.0001, false);
      path.close();
      drawPath(canvas, paint, path, rect);
      return;
    }
    fillPaint(paint, null);
    canvas.drawCircle(center, radius.toDouble(), paint);
  }

  void drawPath(CCanvas canvas, Paint paint, Path path, [Rect? bound]) {
    if (notDraw) {
      return;
    }
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    fillPaint(paint, shader == null ? null : (bound ?? path.getBounds()));
    canvas.drawPath(path, paint);
  }

  void drawArc(CCanvas canvas, Paint paint, Arc arc, [bool useCircleRect = false]) {
    if (notDraw) {
      return;
    }
    if (!isWeb) {
      drawPath(canvas, paint, arc.toPath(), shader == null ? null : arc.getBound(useCircleRect));
      return;
    }
    if (arc.sweepAngle.abs() < Arc.circleMinAngle) {
      drawPath(canvas, paint, arc.toPath(), shader == null ? null : arc.getBound(useCircleRect));
      return;
    }
    if (arc.innerRadius <= 0) {
      drawCircle(canvas, paint, arc.center, arc.outRadius);
      return;
    }

    ///下面是为了解决在Web上Path 裁剪失效导致的形状错乱
    num r = (arc.outRadius - arc.innerRadius);
    paint.reset();
    if (color != null) {
      paint.color = color!;
    }
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = r.toDouble();
    if (shader != null) {
      paint.shader = shader!.toShader(Rect.fromCenter(center: arc.center, width: r * 2, height: r * 2));
    }
    canvas.drawCircle(arc.center, arc.outRadius - r / 2, paint);
  }

  AreaStyle convert(Set<ViewState>? states) {
    if (states == null || states.isEmpty || notDraw) {
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

  static AreaStyle lerp(AreaStyle? start, AreaStyle? end, double t) {
    if (start == end) {
      if (end == null) {
        return AreaStyle.empty;
      }
      return end;
    }
    var c = Color.lerp(start?.color, end?.color, t);
    var ss = start?.shader;
    var es = end?.shader;
    var shader = ChartShader.lerpShader(ss, es, t);
    var shadow = BoxShadow.lerpList(start?.shadow, end?.shadow, t) ?? [];

    if (c == null && shader == null && shadow.isEmpty) {
      return AreaStyle.empty;
    }
    return AreaStyle(color: c, shader: shader, shadow: shadow);
  }
}
