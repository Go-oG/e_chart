import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///基础渲染数据
abstract class RenderData<P> with StateProvider, ExtProps {
  late final String id;
  bool show = true;

  int groupIndex = 0;
  int dataIndex = -1;
  int styleIndex = -1;
  ///绘制顺序(从小到到绘制，最大的最后绘制)
  int drawIndex = -1;

  P? _attr;

  P get attr => _attr!;

  set attr(P a) {
    _attr = a;
  }

  AreaStyle itemStyle = AreaStyle.empty;
  LineStyle borderStyle = LineStyle.empty;
  late TextDraw label = TextDraw(DynamicText.empty, const LabelStyle(), Offset.zero);
  List<Offset> labelLine = [];

  late final DataStatusChangeEvent _dataStateChangeEvent;

  RenderData({String? id, DynamicText? name}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    this.label.text = name ?? DynamicText.empty;

    _dataStateChangeEvent = DataStatusChangeEvent(this, status);
  }

  RenderData.attr(P attr, {String? id, DynamicText? name}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    this.label.text = name ?? DynamicText.empty;
    _dataStateChangeEvent = DataStatusChangeEvent(this, status);
    _attr = attr;
  }

  @override
  bool operator ==(Object other) {
    return other is RenderData && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return '$runtimeType attr:$attr}';
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

  void dispose() {}
}

abstract class RenderData2<P, S extends ChartSymbol> extends RenderData<P> {
  late S symbol;

  RenderData2(this.symbol, {super.id});

  RenderData2.attr(
    this.symbol,
    P attr, {
    super.id,
    super.name,
  }) {
    _attr = attr;
  }

  RenderData2.of({
    super.id,
    super.name,
  });

  @override
  set itemStyle(AreaStyle style) {
    super.itemStyle = style;
    symbol.itemStyle = style;
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
    this.symbol = symbol;
  }

  @override
  NodeAttr toAttr() {
    return NodeAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, symbol.scale);
  }
}

class SymbolNode<T> with StateProvider, ExtProps {
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
