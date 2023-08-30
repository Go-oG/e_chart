import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';

import 'sunburst_node.dart';

/// 旭日图布局计算(以中心点为计算中心)
class SunburstHelper extends LayoutHelper<SunburstSeries> {
  num minRadius = 0;
  num maxRadius = 0;
  num radius = 0;

  SunburstHelper(super.context, super.series);

  ///给定根节点和待布局的节点进行数据的布局
  @override
  void onLayout(LayoutType type) {
    // List<num> radiusList = computeRadius(width, height);
    // minRadius = radiusList[0];
    // maxRadius = radiusList[1];
    // radius = radiusList[2];
    //
    // int deep = root.height;
    //
    // ///深度
    // if (node != root) {
    //   deep += 1;
    // }
    //
    // num diff = radius / deep;
    // Arc arc = buildRootArc(root, node);
    // node.cur = SunburstInfo(arc);
    // node.start = node.cur.copy();
    // node.end = node.cur.copy();
    // node.updatePath(series, 1);
    // int deepOffset = node == root ? 0 : 1;
    // node.eachBefore((tmp, index, startNode) {
    //   if (tmp.hasChild) {
    //     num rd = diff;
    //     if (series.radiusDiffFun != null) {
    //       rd = series.radiusDiffFun!.call(node.height - tmp.height + deepOffset, deep, radius).convert(radius);
    //     }
    //     _layoutChildren(tmp, rd);
    //   }
    //   return false;
    // });
  }

  void _layoutChildren(SunburstNode parent, num radiusDiff) {
    int gapCount = (parent.childCount <= 1) ? 0 : parent.childCount - 1;
    Arc arc = parent.attr.arc;
    if (arc.sweepAngle.abs() >= 359.999) {
      gapCount = 0;
    }
    int dir = series.clockwise ? 1 : -1;
    final num remainAngle = arc.sweepAngle.abs() - series.angleGap.abs() * gapCount;
    num childStartAngle = arc.startAngle;

    final corner = series.corner.abs();
    final angleGap = series.angleGap.abs();
    final radiusGap = series.radiusGap.abs();

    for (var ele in parent.children) {
      double percent = ele.value / parent.value;
      percent = m.min(percent, 1);
      double swa = remainAngle * percent * dir;
      Arc childArc = Arc(
          innerRadius: arc.outRadius + radiusGap,
          outRadius: arc.outRadius + radiusGap + radiusDiff,
          startAngle: childStartAngle,
          sweepAngle: swa,
          cornerRadius: corner,
          padAngle: angleGap);
      ele.attr = SunburstAttr(childArc);
      ele.updatePath(series, 1);
      childStartAngle += swa + angleGap * dir;
    }
  }

  @override
  SeriesType get seriesType => SeriesType.sunburst;

  ///构建根节点的布局数据
  Arc buildRootArc(SunburstNode root, SunburstNode node) {
    int dir = series.clockwise ? 1 : -1;
    num seriesAngle = series.sweepAngle.abs() * dir;
    if (root == node) {
      return Arc(
        innerRadius: 0,
        outRadius: minRadius,
        startAngle: series.offsetAngle,
        sweepAngle: seriesAngle,
      );
    }
    num diff = radius / (node.height + 1);
    if (series.radiusDiffFun != null) {
      diff = series.radiusDiffFun!.call(0, node.height + 1, radius).convert(radius);
    }
    num innerRadius = minRadius + diff;
    if (series.radiusDiffFun != null) {
      diff = series.radiusDiffFun!.call(1, node.height + 1, radius).convert(radius);
    }
    return Arc(
        innerRadius: innerRadius,
        outRadius: innerRadius + diff,
        startAngle: series.offsetAngle,
        sweepAngle: seriesAngle);
  }

  Arc buildBackArc(SunburstNode root, SunburstNode node) {
    int dir = series.clockwise ? 1 : -1;
    num diff = radius / (node.height + 1);
    if (series.radiusDiffFun != null) {
      diff = series.radiusDiffFun!.call(0, node.height + 1, radius).convert(radius);
    }
    return Arc(
      innerRadius: minRadius,
      outRadius: minRadius + diff,
      startAngle: series.offsetAngle,
      sweepAngle: series.sweepAngle.abs() * dir,
    );
  }

  List<num> computeRadius(num width, num height) {
    double minSize = min([width, height]) * 0.5;
    double minRadius = series.innerRadius.convert(minSize);
    double maxRadius = series.outerRadius.convert(minSize);
    return [minRadius, maxRadius, maxRadius - minRadius];
  }
}

