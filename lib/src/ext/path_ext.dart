import 'dart:math';
import 'dart:ui';

import 'paint_ext.dart';
import 'package:flutter/material.dart';

extension PathExt on Path {
  void drawShadows(Canvas canvas,Paint paint, Path path, List<BoxShadow> shadows) {
    paint.reset();
    for (final BoxShadow shadow in shadows) {
      final Paint shadowPainter = shadow.toPaint();
      if (shadow.spreadRadius == 0) {
        canvas.drawPath(path.shift(shadow.offset), shadowPainter);
      } else {
        //关于扩散半径，后续优化
        Rect zone = path.getBounds();
        double xScale = (zone.width + shadow.spreadRadius) / zone.width;
        double yScale = (zone.height + shadow.spreadRadius) / zone.height;
        Matrix4 m4 = Matrix4.identity();
        m4.translate(zone.width / 2, zone.height / 2);
        m4.scale(xScale, yScale);
        m4.translate(-zone.width / 2, -zone.height / 2);
        canvas.drawPath(path.shift(shadow.offset).transform(m4.storage), shadowPainter);
      }
    }
  }
}


///给定一个Path和dash数据返回一个新的Path
Path dashPath(Path path, List<double> dash) {
  if (dash.isEmpty) {
    return path;
  }
  double dashLength = dash[0];
  double dashGapLength = dashLength >= 2 ? dash[1] : dash[0];
  DashedPathProperties properties = DashedPathProperties(
    path: Path(),
    dashLength: dashLength,
    dashGapLength: dashGapLength,
  );
  final metricsIterator = path.computeMetrics().iterator;
  while (metricsIterator.moveNext()) {
    final metric = metricsIterator.current;
    properties.extractedPathLength = 0.0;
    while (properties.extractedPathLength < metric.length) {
      if (properties.addDashNext) {
        properties.addDash(metric, dashLength);
      } else {
        properties.addDashGap(metric, dashGapLength);
      }
    }
  }
  return properties.path;
}

/// 给定一个Path和路径百分比返回给定百分比路径
Path percentPath(Path path, double percent) {
  PathMetrics metrics = path.computeMetrics();
  Path newPath = Path();
  for (PathMetric metric in metrics) {
    Path tmp = metric.extractPath(0, metric.length * percent);
    newPath.addPath(tmp, Offset.zero);
  }
  return newPath;
}

///合并两个Path,并将其头相连，尾相连
Path mergePath(Path p1, Path p2) {
  Path path = p1;
  PathMetric metric = p2.computeMetrics().single;
  double length = metric.length;
  while (length >= 0) {
    Tangent? t = metric.getTangentForOffset(length);
    if (t != null) {
      Offset offset = t.position;
      path.lineTo(offset.dx, offset.dy);
    }
    length -= 1;
  }
  path.close();
  return path;
}

///用于实现 path dash
class DashedPathProperties {
  double extractedPathLength;
  Path path;

  final double _dashLength;
  double _remainingDashLength;
  double _remainingDashGapLength;
  bool _previousWasDash;

  DashedPathProperties({
    required this.path,
    required double dashLength,
    required double dashGapLength,
  })  : assert(dashLength > 0.0, 'dashLength must be > 0.0'),
        assert(dashGapLength > 0.0, 'dashGapLength must be > 0.0'),
        _dashLength = dashLength,
        _remainingDashLength = dashLength,
        _remainingDashGapLength = dashGapLength,
        _previousWasDash = false,
        extractedPathLength = 0.0;

  bool get addDashNext {
    if (!_previousWasDash || _remainingDashLength != _dashLength) {
      return true;
    }
    return false;
  }

  void addDash(PathMetric metric, double dashLength) {
    final end = _calculateLength(metric, _remainingDashLength);
    final availableEnd = _calculateLength(metric, dashLength);
    final pathSegment = metric.extractPath(extractedPathLength, end);
    path.addPath(pathSegment, Offset.zero);
    final delta = _remainingDashLength - (end - extractedPathLength);
    _remainingDashLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashLength,
    );
    extractedPathLength = end;
    _previousWasDash = true;
  }

  void addDashGap(PathMetric metric, double dashGapLength) {
    final end = _calculateLength(metric, _remainingDashGapLength);
    final availableEnd = _calculateLength(metric, dashGapLength);
    Tangent tangent = metric.getTangentForOffset(end)!;
    path.moveTo(tangent.position.dx, tangent.position.dy);
    final delta = end - extractedPathLength;
    _remainingDashGapLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashGapLength,
    );
    extractedPathLength = end;
    _previousWasDash = false;
  }

  double _calculateLength(PathMetric metric, double addedLength) {
    return min(extractedPathLength + addedLength, metric.length);
  }

  double _updateRemainingLength({
    required double delta,
    required double end,
    required double availableEnd,
    required double initialLength,
  }) {
    return (delta > 0 && availableEnd == end) ? delta : initialLength;
  }
}