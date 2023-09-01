import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointNode extends DataNode<PointAttr, PointData> {
  final PointGroup group;
  ChartSymbol symbol;

  PointNode(
    this.symbol,
    this.group,
    PointData data,
    int dataIndex,
    int groupIndex,
  ) : super(data, dataIndex, groupIndex, PointAttr(), AreaStyle.empty, LineStyle.empty, LabelStyle.empty);

  @override
  bool contains(Offset offset) {
    return symbol.internal2(attr.offset, attr.size, offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    symbol.draw2(canvas, paint, attr.offset, attr.size);
    var label = data.label;
    var labelConfig = attr.labelConfig;
    if (label != null && label.isNotEmpty && labelConfig != null) {
      labelStyle.draw(canvas, paint, label, labelConfig);
    }
  }

  @override
  void updateStyle(Context context, covariant PointSeries series) {
    symbol = series.symbolFun.call(data, group, status);
  }
}

class PointAttr {
  Offset offset = Offset.zero;
  Size size = Size.zero;
  TextDrawInfo? labelConfig;

  PointAttr();

  PointAttr.all(this.offset, this.size);

  @override
  String toString() {
    return "$runtimeType offset:$offset size:$size";
  }
}
