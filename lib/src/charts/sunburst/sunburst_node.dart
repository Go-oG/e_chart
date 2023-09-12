import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class SunburstNode extends TreeNode<TreeData, SunburstAttr, SunburstNode> {
  SunburstNode(
    SunburstNode? parent,
    TreeData data,
    int dataIndex, {
    super.maxDeep,
    super.deep,
    super.groupIndex,
    super.value,
  }) : super(parent, data, dataIndex, SunburstAttr.zero(), AreaStyle.empty, LineStyle.empty, LabelStyle.empty);

  void updateTextPosition(SunburstSeries series) {
    attr._updateTextPosition(series, this);
  }

  @override
  bool contains(Offset offset) {
    return attr.arc.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawArc(canvas, paint, attr.arc);
    borderStyle.drawPath(canvas, paint, attr.arc.toPath());
    labelStyle.draw(canvas, paint, "D$deep:${data.value}".toText(), TextDrawInfo(attr.arc.centroid()));
    // _drawText(canvas, paint);
  }

  void _drawText(CCanvas canvas, Paint paint) {
    Arc arc = attr.arc;
    var style = labelStyle;
    var label = data.label;
    var config = labelConfig;
    if (config == null || label == null || label.isEmpty || !style.show || arc.sweepAngle.abs() <= style.minAngle) {
      return;
    }
    style.draw(canvas, paint, label, config);
    // TextDrawInfo config = TextDrawInfo(
    //   node.attr.textPosition,
    //   align: Alignment.center,
    //   maxWidth: arc.outRadius - arc.innerRadius,
    //   rotate: node.attr.textRotateAngle,
    // );
  }

  @override
  void updateStyle(Context context, covariant SunburstSeries series) {
    itemStyle = series.getAreaStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    labelStyle = series.getLabelStyle(context, this);
  }

  @override
  String toString() {
    var s = super.toString();
    return "$s\nAttr:\n$attr";
  }
}

class SunburstVirtualNode extends SunburstNode {
  SunburstVirtualNode(SunburstNode child, SunburstAttr attr) : super(null, child.data, 0) {
    child.parent = null;
    add(child);
    value = child.value;
    this.attr = attr;
  }

  final AreaStyle bs = const AreaStyle(color: Colors.black);

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    bs.drawArc(canvas, paint, attr.arc);
  }
}

/// 存放位置数据
class SunburstAttr {
  static final SunburstAttr empty = SunburstAttr(Arc());
  Arc arc;

  SunburstAttr(this.arc, {this.textPosition = Offset.zero, this.textRotateAngle = 0, this.alpha = 1});

  SunburstAttr.zero() : arc = Arc();

  Offset textPosition = Offset.zero;
  double textRotateAngle = 0;
  double alpha = 1;

  /// 更新绘制相关的Path
  void _updateTextPosition(SunburstSeries series, SunburstNode node) {
    textPosition = Offset.zero;
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



  @override
  String toString() {
    return "Arc:$arc";
  }
}
