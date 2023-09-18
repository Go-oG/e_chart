import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class PieNode extends DataNode<Arc, ItemData> {
  PieNode(
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  ///计算文字的位置
  TextDrawInfo? textDrawConfig;
  Path? guidLinePath;

  void updateTextPosition(PieSeries series) {
    textDrawConfig = null;
    guidLinePath = null;
    var labelStyle = this.labelStyle;
    if (series.labelAlign == CircleAlign.center) {
      textDrawConfig = TextDrawInfo(attr.center, align: Alignment.center);
    } else if (series.labelAlign == CircleAlign.inside) {
      double radius = (attr.innerRadius + attr.outRadius) / 2;
      double angle = attr.startAngle + attr.sweepAngle / 2;
      Offset offset = circlePoint(radius, angle).translate(attr.center.dx, attr.center.dy);
      textDrawConfig = TextDrawInfo(offset, align: Alignment.center);
    } else if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle.guideLine?.length ?? 0;
      double centerAngle = attr.startAngle + attr.sweepAngle / 2;
      Offset offset = circlePoint(attr.outRadius + expand, centerAngle, attr.center);
      Alignment align = toAlignment(centerAngle, false);
      if (centerAngle >= 90 && centerAngle <= 270) {
        align = Alignment.centerRight;
      } else {
        align = Alignment.centerLeft;
      }
      textDrawConfig = TextDrawInfo(offset, align: align);
    }

    var config = textDrawConfig;
    if (config == null) {
      return;
    }

    if (series.labelAlign == CircleAlign.outside) {
      Offset center = attr.center;
      Offset tmpOffset = circlePoint(attr.outRadius, attr.startAngle + (attr.sweepAngle / 2), center);
      Offset tmpOffset2 = circlePoint(
        attr.outRadius + (labelStyle.guideLine?.length ?? 0),
        attr.startAngle + (attr.sweepAngle / 2),
        center,
      );
      Path path = Path();
      path.moveTo(tmpOffset.dx, tmpOffset.dy);
      path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
      path.lineTo(config.offset.dx, config.offset.dy);
      guidLinePath = path;
    }
  }

  @override
  bool contains(Offset offset) {
    return offset.inArc(attr);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawArc(canvas, paint, attr);
    borderStyle.drawPath(canvas, paint, attr.toPath());

    var ls = labelStyle;
    var config = textDrawConfig;
    var label = data.name;
    if (guidLinePath != null) {
      ls.guideLine?.style.drawPath(canvas, paint, guidLinePath!);
    }

    if (ls.show && config != null && label != null && label.isNotEmpty) {
      if (attr.center == config.offset) {
        if (isHover || isFocused || isActivated || isDragged || isPressed) {
          ls.draw(canvas, paint, label, config);
        }
      }
    }
  }

  @override
  void updateStyle(Context context, PieSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
  }
}
