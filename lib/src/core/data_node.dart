import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///数据到绘图节点的映射
abstract class DataNode<P, D> with ViewStateProvider, ExtProps {
  D data;

  int dataIndex;

  int groupIndex;

  P? _attr;

  P get attr => _attr!;

  set attr(P a) {
    _attr = a;
  }

  ///绘制顺序(从小到到绘制，最大的最后绘制)
  int drawIndex = 0;
  TextDraw label = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero);

  List<Offset> labelLine = [];

  late AreaStyle itemStyle;
  late LineStyle borderStyle;

  late final DataStatusChangeEvent _dataStateChangeEvent;

  DataNode(
    this.data,
    this.dataIndex,
    this.groupIndex,
    P attr,
    this.itemStyle,
    this.borderStyle,
    LabelStyle labelStyle,
  ) {
    _dataStateChangeEvent = DataStatusChangeEvent(data, status);
    _attr = attr;
    label.style = labelStyle;
  }

  DataNode.empty(this.data, this.dataIndex, this.groupIndex, P attr) {
    _dataStateChangeEvent = DataStatusChangeEvent(data, status);
    itemStyle = AreaStyle.empty;
    borderStyle = LineStyle.empty;
    label.style = LabelStyle.empty;
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

  void onDraw(CCanvas canvas, Paint paint);

  void onDrawSymbol(CCanvas canvas, Paint paint) {}

  bool contains(Offset offset);

  NodeAttr toAttr() {
    return NodeAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, 1);
  }

  void updateStyle(Context context, covariant ChartSeries series);

  bool updateStatus(Context context, Iterable<ViewState>? remove, Iterable<ViewState>? add) {
    if ((remove == null || remove.isEmpty) && (add == null || add.isEmpty)) {
      return false;
    }
    if (equalSet<ViewState>(remove, add)) {
      return false;
    }
    if (remove != null) {
      removeStates(remove);
    }
    if (add != null) {
      addStates(add);
    }
    if (context.hasEventListener(EventType.dataStatusChanged)) {
      context.dispatchEvent(_dataStateChangeEvent);
    }
    return true;
  }

  void sendStateChangeEvent(Context context) {
    if (context.hasEventListener(EventType.dataStatusChanged)) {
      context.dispatchEvent(_dataStateChangeEvent);
    }
  }

  ///更新当前符号的大小
  void updateSymbolSize(Size size) {}

  void updateLabelPosition(Context context, covariant ChartSeries series) {}

  DataType get dataType => DataType.nodeData;

  void dispose(){}
}

abstract class DataNode2<P, D, S extends ChartSymbol> extends DataNode<P, D> {
  late S _symbol;

  S get symbol => _symbol;

  DataNode2(
    S symbol,
    D data,
    int dataIndex,
    int groupIndex,
    P attr,
    LabelStyle labelStyle,
  ) : super(
          data,
          dataIndex,
          groupIndex,
          attr,
          symbol.itemStyle,
          symbol.borderStyle,
          labelStyle,
        ) {
    _symbol = symbol;
  }

  @override
  set itemStyle(AreaStyle style) {
    super.itemStyle = style;
    _symbol.itemStyle = style;
  }

  @override
  set borderStyle(LineStyle style) {
    super.borderStyle = style;
    symbol.borderStyle = style;
  }

  void setSymbol(S symbol, bool styleUseSymbol) {
    if (styleUseSymbol) {
      itemStyle = symbol.itemStyle;
      borderStyle = symbol.borderStyle;
    } else {
      symbol.borderStyle = borderStyle;
      symbol.itemStyle = itemStyle;
    }
    this._symbol = symbol;
  }

  @override
  NodeAttr toAttr() {
    return NodeAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, symbol.scale);
  }
}

class SymbolNode<T> with ViewStateProvider, ExtProps {
  T data;
  ChartSymbol symbol = EmptySymbol();
  int dataIndex;
  int groupIndex;

  Offset center = Offset.zero;

  SymbolNode(this.data, this.symbol, this.dataIndex, this.groupIndex);

  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, center);
  }

  bool contains(Offset offset) {
    return symbol.contains(center, offset);
  }
}

class NodeAttr {
  final dynamic attr;
  final int drawIndex;
  final TextDraw label;
  final List<Offset>? labelLine;
  final AreaStyle itemStyle;
  final LineStyle borderStyle;
  final double symbolScale;

  const NodeAttr(
    this.attr,
    this.drawIndex,
    this.label,
    this.labelLine,
    this.itemStyle,
    this.borderStyle,
    this.symbolScale,
  );
}
