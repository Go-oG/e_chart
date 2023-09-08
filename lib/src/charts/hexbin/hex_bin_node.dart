import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HexbinNode extends DataNode<HexAttr, ItemData> {
  HexbinNode(
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  @override
  void onDraw(Canvas canvas, Paint paint) {
    Path path = attr.shape.toPath();
    itemStyle.drawPath(canvas, paint, path);
    var lineStyle = borderStyle;
    if (lineStyle.canDraw) {
      num r = attr.shape.r;
      double scale = 1 - (lineStyle.width / (2 * r));
      Matrix4 m4 = Matrix4.identity();
      m4.translate(attr.center.dx, attr.center.dy);
      m4.scale(scale, scale);
      m4.translate(-attr.center.dx, -attr.center.dy);
      var path2 = path.transform(m4.storage);
      lineStyle.drawPath(canvas, paint, path2, drawDash: true, needSplit: false);
    }
    DynamicText? s = data.label;
    if (s == null || s.isEmpty) {
      return;
    }
    var ls = labelStyle;
    if (ls.show) {
      TextDrawInfo config = TextDrawInfo(attr.center, textAlign: TextAlign.center);
      ls.draw(canvas, paint, s, config);
    }
  }

  @override
  bool contains(Offset offset) {
    return attr.shape.toPath().contains(offset);
  }

  @override
  void updateStyle(Context context, HexbinSeries series) {
    itemStyle = series.getItemStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
  }
}

class HexAttr {
  static final HexAttr zero = HexAttr.all(Hex(0, 0, 0), PositiveShape(count: 0), Offset.zero);
  final Hex hex;
  late PositiveShape shape;
  late Offset center;
  double alpha = 1;

  HexAttr(this.hex);

  HexAttr.all(this.hex, this.shape, this.center);

  HexAttr copy({double? alpha}) {
    var attr = HexAttr.all(hex, shape, center);
    attr.alpha = alpha ?? this.alpha;
    return attr;
  }
}
