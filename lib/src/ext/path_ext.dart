import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

extension PathExt on Path {
  void drawShadows(Canvas canvas, Path path, List<BoxShadow> shadows) {
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

  ///给定一个Path和dash数据返回一个新的Path
  Path dashPath(List<num> dash) {
    if (dash.isEmpty) {
      return this;
    }
    num dashLength = dash[0];
    num dashGapLength = dashLength >= 2 ? dash[1] : dash[0];
    DashedPathProperties properties = DashedPathProperties(
      path: Path(),
      dashLength: dashLength,
      dashGapLength: dashGapLength,
    );
    final metricsIterator = computeMetrics().iterator;
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
  Path percentPath(double percent) {
    if (percent >= 1) {
      return this;
    }
    if (percent <= 0) {
      return Path();
    }
    PathMetrics metrics = computeMetrics();
    Path newPath = Path();
    for (PathMetric metric in metrics) {
      Path tmp = metric.extractPath(0, metric.length * percent);
      newPath.addPath(tmp, Offset.zero);
    }
    return newPath;
  }

  //返回路径百分比上的一点
  Offset? percentOffset(double percent) {
    PathMetrics metrics = computeMetrics();
    for (PathMetric metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      var result = metric.getTangentForOffset(metric.length * percent);
      if (result == null) {
        continue;
      }

      return result.position;
    }
    return null;
  }

  Offset? firstOffset() {
    PathMetrics metrics = computeMetrics();
    for (PathMetric metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      var result = metric.getTangentForOffset(1);
      if (result == null) {
        continue;
      }
      return result.position;
    }
    return null;
  }

  Offset? lastOffset() {
    PathMetrics metrics = computeMetrics();
    List<Offset> ol = [];
    for (PathMetric metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      var result = metric.getTangentForOffset(metric.length);
      if (result == null) {
        continue;
      }
      ol.add(result.position);
    }
    if (ol.isEmpty) {
      return null;
    }
    return ol[ol.length - 1];
  }

  ///将当前Path进行拆分
  List<Path> split([double maxLength = 300]) {
    List<Path> pathList = [];

    PathMetrics metrics = computeMetrics();
    for (PathMetric metric in metrics) {
      final double length = metric.length;
      if (metric.length <= 0) {
        continue;
      }
      if (length <= maxLength) {
        pathList.add(metric.extractPath(0, length));
        continue;
      }
      double start = 0;
      while (start < length) {
        double end = start + maxLength;
        if (end > length) {
          end = length;
        }
        pathList.add(metric.extractPath(start, end));
        if (end >= length) {
          break;
        }
        start += maxLength;
      }
    }
    return pathList;
  }

  ///合并两个Path,并将其头相连，尾相连
  Path mergePath(Path p2) {
    Path path = this;
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

  void moveTo2(Offset offset) {
    moveTo(offset.dx, offset.dy);
  }

  void lineTo2(Offset offset) {
    lineTo(offset.dx, offset.dy);
  }
}

///用于实现 path dash
class DashedPathProperties {
  num extractedPathLength;
  Path path;

  final num _dashLength;
  num _remainingDashLength;
  num _remainingDashGapLength;
  bool _previousWasDash;

  DashedPathProperties({
    required this.path,
    required num dashLength,
    required num dashGapLength,
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

  void addDash(PathMetric metric, num dashLength) {
    final end = _calculateLength(metric, _remainingDashLength).toDouble();
    final availableEnd = _calculateLength(metric, dashLength);
    final pathSegment = metric.extractPath(extractedPathLength.toDouble(), end);
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

  void addDashGap(PathMetric metric, num dashGapLength) {
    final end = _calculateLength(metric, _remainingDashGapLength);
    final availableEnd = _calculateLength(metric, dashGapLength);
    Tangent tangent = metric.getTangentForOffset(end.toDouble())!;
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

  num _calculateLength(PathMetric metric, num addedLength) {
    return min(extractedPathLength + addedLength, metric.length);
  }

  num _updateRemainingLength({
    required num delta,
    required num end,
    required num availableEnd,
    required num initialLength,
  }) {
    return (delta > 0 && availableEnd == end) ? delta : initialLength;
  }
}
