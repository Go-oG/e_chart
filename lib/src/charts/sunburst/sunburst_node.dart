import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class SunburstNode extends TreeNode<TreeData, SunburstAttr, SunburstNode> {
  SunburstNode(
    super.parent,
    super.data,
    super.dataIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  updatePath(SunburstSeries series, double animatorPercent) {
    attr._updatePath(series, animatorPercent, this);
  }

  @override
  bool contains(Offset offset) {
    return attr.arc.toPath(true).contains(offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    itemStyle.drawPath(canvas, paint, attr.shapePath!);
    borderStyle.drawPath(canvas, paint, attr.shapePath!);
  }
}

/// 存放位置数据
class SunburstAttr {
  static SunburstAttr zero = SunburstAttr(Arc());
  Arc arc;

  SunburstAttr(this.arc, {this.textPosition = Offset.zero, this.textRotateAngle = 0, this.alpha = 1});

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
    LabelStyle? style = series.labelStyleFun?.call(node);
    if (style == null) {
      return;
    }
    double originAngle = arc.startAngle + arc.sweepAngle / 2;
    Size size = style.measure(node.data.label!, maxWidth: arc.outRadius - arc.innerRadius);
    double labelMargin = series.labelMarginFun?.call(node) ?? 0;
    if (labelMargin > 0) {
      size = Size(size.width + labelMargin, size.height);
    }

    double dx = m.cos(originAngle * Constants.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    double dy = m.sin(originAngle * Constants.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    Align2 align = series.labelAlignFun?.call(node) ?? Align2.start;
    if (align == Align2.start) {
      dx = m.cos(originAngle * Constants.angleUnit) * (arc.innerRadius + size.width / 2);
      dy = m.sin(originAngle * Constants.angleUnit) * (arc.innerRadius + size.width / 2);
    } else if (align == Align2.end) {
      dx = m.cos(originAngle * Constants.angleUnit) * (arc.outRadius - size.width / 2);
      dy = m.sin(originAngle * Constants.angleUnit) * (arc.outRadius - size.width / 2);
    }
    textPosition = Offset(dx, dy);

    double rotateMode = series.rotateFun?.call(node) ?? -1;
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
      center: arc.center,
    ).toPath(true);
  }

  SunburstAttr copy() {
    return SunburstAttr(
      arc.copy(),
      textPosition: textPosition,
      textRotateAngle: textRotateAngle,
      alpha: alpha,
    );
  }
}
