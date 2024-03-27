import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../helper/state_resolver.dart';

///基础渲染数据
abstract class RenderData<T> extends Disposable with StateProvider, ExtProps {
  late final String id;
  bool show = true;
  int groupIndex = 0;
  int dataIndex = -1;
  int styleIndex = -1;

  ///绘制顺序(从小到到绘制，最大的最后绘制)
  int drawIndex = -1;

  AreaStyle itemStyle = AreaStyle.empty;

  LineStyle borderStyle = LineStyle.empty;

  late TextDraw label = TextDraw(DynamicText.empty, const LabelStyle(), Offset.zero);

  late List<Offset> labelLine = [];

  late final DataStatusChangeEvent _dataStateChangeEvent;

  T? _attr;

  set attr(T attr) {
    _attr = attr;
  }

  T get attr {
    return _attr!;
  }

  T? get attrNull {
    return _attr;
  }

  RenderData({String? id, DynamicText? name}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    label.text = name ?? DynamicText.empty;
    _dataStateChangeEvent = DataStatusChangeEvent(this, status);
    _attr = initAttr();
  }

  T initAttr();

  @override
  bool operator ==(Object other) {
    return other is RenderData && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  void onDraw(CCanvas canvas, Paint paint);

  void onDrawSymbol(CCanvas canvas, Paint paint) {}

  bool contains(Offset offset);

  DataAttr toAttr() {
    return DataAttr(null, drawIndex, label, labelLine, itemStyle, borderStyle, 1);
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

  void updateLabelPosition(Context context, covariant ChartSeries series) {}

  Color pickColor() {
    var c = itemStyle.pickColor();
    if (c != null && c != Colors.transparent) {
      return c;
    }
    c = borderStyle.pickColor();
    if (c != null && c != Colors.transparent) {
      return c;
    }
    return Colors.transparent;
  }

  DataType get dataType => DataType.nodeData;

  @override
  void dispose() {
    super.dispose();
    cleanState();
    itemStyle = AreaStyle.empty;
    borderStyle = LineStyle.empty;
    label.dispose();
  }

  void checkLayoutResultType(LayoutResult result, Type type) {
    if (result.runtimeType == type) {
      return;
    }
    throw ChartError("输入${result.runtimeType} 接受:$type");
  }
}

abstract class RenderData2<T, S extends ChartSymbol> extends RenderData<T> {
  S? _symbol;

  RenderData2({
    super.id,
    super.name,
  });

  S get symbol => _symbol!;

  set symbol(S s) => _symbol = s;

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
  DataAttr toAttr() {
    return DataAttr(null, drawIndex, label, labelLine, itemStyle, borderStyle, symbol.scale);
  }
}

abstract class RenderGroupData<T extends RenderData> extends RenderData<String> {
  List<T> data;

  RenderGroupData(
    this.data, {
    super.id,
    super.name,
  }) : super();

  @override
  bool contains(Offset offset) {
    for (var c in data) {
      if (c.contains(offset)) {
        return true;
      }
    }
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    each(data, (p0, p1) {
      p0.onDraw(canvas, paint);
    });
  }

  @override
  void onDrawSymbol(CCanvas canvas, Paint paint) {
    each(data, (p0, p1) {
      p0.onDrawSymbol(canvas, paint);
    });
  }

  @override
  void updateStyle(Context context, covariant ChartSeries series) {
    each(data, (p0, p1) {
      p0.updateStyle(context, series);
    });
  }

  @override
  String initAttr() => "";
}

abstract class RenderChildData<T, P extends RenderGroupData, L> extends RenderData<L> {
  T? data;

  RenderChildData(this.data, {super.id, super.name});

  @override
  void onDrawSymbol(CCanvas canvas, Paint paint) {
    symbol?.draw(canvas, paint, center);
  }

  P get parent => extGet("exParent");

  set parent(P p) => extSet("exParent", p);

  ChartSymbol? get symbol => extGetNull("exSymbol");

  set symbol(ChartSymbol? s) => extSet("exSymbol", s);

  Offset get center => extGet("exCenter");

  set center(Offset p) => extSet("exCenter", p);

  bool get dataIsNull => data == null;
}

class DataAttr {
  final dynamic attr;
  final int drawIndex;
  final TextDraw label;
  final List<Offset>? labelLine;
  final AreaStyle itemStyle;
  final LineStyle borderStyle;
  final double symbolScale;

  const DataAttr(
    this.attr,
    this.drawIndex,
    this.label,
    this.labelLine,
    this.itemStyle,
    this.borderStyle,
    this.symbolScale,
  );
}
