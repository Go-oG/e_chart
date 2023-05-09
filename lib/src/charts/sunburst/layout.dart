import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'package:xutil/xutil.dart';
import '../../model/constans.dart';
import '../../model/enums/align2.dart';
import '../../model/tree_data.dart';
import '../../shape/arc.dart';
import '../../style/label.dart';
import 'sunburst_series.dart';

/// 旭日图布局计算(以中心点为计算中心)
class SunburstLayout {
  ///给定根节点和待布局的节点进行数据的布局
  void layout(SunburstSeries series, SunburstNode root, SunburstNode node, num width, num height) {
    int deep = node.height;

    ///深度
    if (node != root) {
      deep += 1;
    }
    num radius = computeRadius(series, width, height)[2];
    num diff = radius / deep;
    Arc arc = buildRootArc(series, root, node, width, height);
    node.cur = SunburstInfo(arc);
    node.start = node.cur.copy();
    node.end = node.cur.copy();
    int deepOffset = node == root ? 0 : 1;
    node.eachBefore((tmp, index, startNode) {
      if (tmp.hasChild) {
        num rd = diff;
        if (series.radiusDiffFun != null) {
          rd = series.radiusDiffFun!.call(node.height - tmp.height + deepOffset, deep, radius).convert(radius);
        }
        _innerLayout(series, tmp, tmp.cur.arc, rd);
      }
      return false;
    });
  }

  void _innerLayout(SunburstSeries series, SunburstNode node, Arc arc, num radiusDiff) {
    node.cur = SunburstInfo(arc);
    node.updatePath(series, 1);
    int gapCount = node.childCount - 1;
    if (arc.sweepAngle.abs() >= 359.999) {
      gapCount += 1;
    }
    if (node.childCount <= 1) {
      gapCount = 0;
    }
    num remainAngle = arc.sweepAngle - series.angleGap * gapCount;
    num childStartAngle = arc.startAngle;
    for (var ele in node.children) {
      double percent = ele.value / node.value;
      percent = m.min(percent, 1);
      Arc childArc = Arc(
        innerRadius: arc.outRadius + series.radiusGap,
        outRadius: arc.outRadius + series.radiusGap + radiusDiff,
        startAngle: childStartAngle,
        sweepAngle: remainAngle * percent,
        cornerRadius: series.corner,
        padAngle: series.angleGap,
      );
      ele.cur = SunburstInfo(childArc);
      ele.updatePath(series, 1);
      childStartAngle += ele.cur.arc.sweepAngle + series.angleGap;
    }
  }

  ///构建根节点的布局数据
  Arc buildRootArc(SunburstSeries series, SunburstNode root, SunburstNode node, num width, num height) {
    double minSize = m.min(width, height) * 0.5;
    double minRadius = series.innerRadius.convert(minSize);
    double maxRadius = series.outerRadius.convert(minSize);
    if (root == node) {
      return Arc(innerRadius: 0, outRadius: minRadius, startAngle: 0, sweepAngle: 360);
    }

    num radius = maxRadius - minRadius;
    num diff = radius / (node.height + 1);
    if (series.radiusDiffFun != null) {
      diff = series.radiusDiffFun!.call(0, node.height + 1, radius).convert(radius);
    }
    num innerRadius = minRadius + diff;
    if (series.radiusDiffFun != null) {
      diff = series.radiusDiffFun!.call(1, node.height + 1, radius).convert(radius);
    }

    return Arc(innerRadius: innerRadius, outRadius: innerRadius + diff, startAngle: 0, sweepAngle: 360);
  }

  Arc buildBackArc(SunburstSeries series, SunburstNode root, SunburstNode node, num width, num height) {
    double minSize = m.min(width, height) * 0.5;
    double minRadius = series.innerRadius.convert(minSize);
    double maxRadius = series.outerRadius.convert(minSize);
    num radius = maxRadius - minRadius;
    num diff = radius / (node.height + 1);
    if (series.radiusDiffFun != null) {
      diff = series.radiusDiffFun!.call(0, node.height + 1, radius).convert(radius);
    }
    return Arc(innerRadius: minRadius, outRadius: minRadius + diff, startAngle: 0, sweepAngle: 360);
  }

  List<num> computeRadius(SunburstSeries series, num width, num height) {
    double minSize = min([width, height])! * 0.5;
    double minRadius = series.innerRadius.convert(minSize);
    double maxRadius = series.outerRadius.convert(minSize);
    return [minRadius, maxRadius, maxRadius - minRadius];
  }
}

class SunburstNode extends TreeNode<SunburstNode> {
  final TreeData data;
  SunburstInfo cur = SunburstInfo.zero; // 当前帧
  SunburstInfo start = SunburstInfo.zero; //动画开始帧
  SunburstInfo end = SunburstInfo.zero; // 动画结束帧

  SunburstNode(
    super.parent,
    this.data, {
    super.value,
    super.deep,
    super.maxDeep,
  });

  updatePath(SunburstSeries series, double animatorPercent) {
    cur._updatePath(series, animatorPercent, this);
  }
}

/// 存放位置数据
class SunburstInfo {
  static SunburstInfo zero = SunburstInfo(Arc());
  final Arc arc;

  SunburstInfo(this.arc, {this.textPosition = Offset.zero, this.textRotateAngle = 0, this.alpha = 1});

  Offset textPosition = Offset.zero;
  double textRotateAngle = 0;
  double alpha = 1;

  Path? shapePath;

  /// 更新绘制相关的Path
  void _updatePath(SunburstSeries series, double animatorPercent, SunburstNode node) {
    shapePath = _buildShapePath(animatorPercent);
    _computeTextPosition(series, node);
  }

  /// 计算label的位置
  void _computeTextPosition(SunburstSeries series, SunburstNode node) {
    textPosition = Offset.zero;
    if (node.data.label == null || node.data.label!.isEmpty) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node, null);
    if (style == null) {
      return;
    }
    double originAngle = arc.startAngle + arc.sweepAngle / 2;
    Size size = style.measure(node.data.label!, maxWidth: arc.outRadius - arc.innerRadius);
    double labelMargin = series.labelMarginFun?.call(node, null) ?? 0;
    if (labelMargin > 0) {
      size = Size(size.width + labelMargin, size.height);
    }

    double dx = m.cos(originAngle * Constants.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    double dy = m.sin(originAngle * Constants.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    Align2 align = series.labelAlignFun?.call(node, null) ?? Align2.start;
    if (align == Align2.start) {
      dx = m.cos(originAngle * Constants.angleUnit) * (arc.innerRadius + size.width / 2);
      dy = m.sin(originAngle * Constants.angleUnit) * (arc.innerRadius + size.width / 2);
    } else if (align == Align2.end) {
      dx = m.cos(originAngle * Constants.angleUnit) * (arc.outRadius - size.width / 2);
      dy = m.sin(originAngle * Constants.angleUnit) * (arc.outRadius - size.width / 2);
    }
    textPosition = Offset(dx, dy);

    double rotateMode = series.rotateFun?.call(node, null) ?? -1;
    double rotateAngle = 0;

    if (rotateMode <= -2) {
      ///切向
      if (originAngle >= 360) {
        originAngle = originAngle % 360;
      }
      if (originAngle >= 0 && originAngle < 90) {
        rotateAngle = originAngle % 90;
      } else if (originAngle >= 90 && originAngle < 270) {
        rotateAngle = originAngle - 180;
      } else {
        rotateAngle = originAngle - 360;
      }
    } else if (rotateMode <= -1) {
      ///径向
      if (originAngle >= 360) {
        originAngle = originAngle % 360;
      }
      if (originAngle >= 0 && originAngle < 180) {
        rotateAngle = originAngle - 90;
      } else {
        rotateAngle = originAngle - 270;
      }
    } else if (rotateMode > 0) {
      rotateAngle = rotateMode;
    }
    textRotateAngle = rotateAngle;
  }

  /// 将布局后的图形转换为Path
  Path _buildShapePath(double percent) {
    num ir = arc.innerRadius;
    num or = arc.innerRadius + (arc.outRadius - arc.innerRadius) * percent;
    return Arc(
      innerRadius: ir,
      outRadius: or,
      startAngle: arc.startAngle,
      sweepAngle: arc.sweepAngle,
      cornerRadius: arc.cornerRadius,
      padAngle: arc.padAngle,
    ).path(true);
  }

  SunburstInfo copy() {
    return SunburstInfo(
      arc.copy(),
      textPosition: textPosition,
      textRotateAngle: textRotateAngle,
      alpha: alpha,
    );
  }
}
