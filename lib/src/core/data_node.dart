import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///数据到绘图节点的映射
abstract class DataNode<P, D> with ViewStateProvider, ExtProps {
  final int dataIndex;
  final int groupIndex;
  final D data;
  late P _attr;

  P get attr => _attr;

  set attr(P a) {
    _attr = a;
  }

  ///绘制顺序(从小到到绘制，最大的最后绘制)
  int drawIndex = 0;

  DynamicText? label;
  TextDrawInfo? labelConfig;
  List<Offset>? labelLine;

  AreaStyle itemStyle;
  LineStyle borderStyle;
  LabelStyle labelStyle;

  DataNode(
    this.data,
    this.dataIndex,
    this.groupIndex,
    P attr,
    this.itemStyle,
    this.borderStyle,
    this.labelStyle,
  ) {
    _attr = attr;
  }

  @override
  bool operator ==(Object other) {
    return other is DataNode && other.data == data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  void onDraw(Canvas canvas, Paint paint);

  void onDrawSymbol(Canvas canvas, Paint paint) {}

  bool contains(Offset offset);

  NodeAttr toAttr() {
    return NodeAttr(attr, drawIndex, label, labelConfig, labelLine, itemStyle, borderStyle, labelStyle);
  }

  void updateStyle(Context context, covariant ChartSeries series);
}

class NodeAttr<A> {
  final A attr;
  final int drawIndex;

  final DynamicText? label;
  final TextDrawInfo? labelConfig;
  final List<Offset>? labelLine;
  final AreaStyle itemStyle;
  final LineStyle borderStyle;
  final LabelStyle labelStyle;

  const NodeAttr(
    this.attr,
    this.drawIndex,
    this.label,
    this.labelConfig,
    this.labelLine,
    this.itemStyle,
    this.borderStyle,
    this.labelStyle,
  );
}
