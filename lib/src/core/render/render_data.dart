import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///基础渲染数据
abstract class RenderData<P> extends Disposable with StateProvider, ExtProps {
  late final String id;
  bool show = true;
  int groupIndex = 0;
  int dataIndex = -1;
  int styleIndex = -1;

  ///绘制顺序(从小到到绘制，最大的最后绘制)
  int drawIndex = -1;

  P? _attr;

  P get attr => _attr!;

  P? get attrNull => _attr;

  set attr(P a) {
    var old = _attr;
    _attr = a;
    if (!identical(a, old) && old != null) {
      if (old is Disposable) {
        old.dispose();
      } else if (old is Disposable) {
        old.dispose();
      }
    }
  }

  AreaStyle itemStyle = AreaStyle.empty;
  LineStyle borderStyle = LineStyle.empty;
  late TextDraw label = TextDraw(DynamicText.empty, const LabelStyle(), Offset.zero);
  late List<Offset> labelLine = [];

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

  DataAttr toAttr() {
    return DataAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, 1);
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
    var old = _attr;
    _attr = null;
    if (old != null && old is Disposable) {
      old.dispose();
    }
    itemStyle = AreaStyle.empty;
    borderStyle = LineStyle.empty;
    label.dispose();
  }
}

abstract class RenderData2<P, S extends ChartSymbol> extends RenderData<P> {
  S? _symbol;

  S get symbol => _symbol!;

  set symbol(S s) => _symbol = s;

  RenderData2({
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
  DataAttr toAttr() {
    return DataAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, symbol.scale);
  }
}

abstract class RenderGroupData<T extends RenderData> extends RenderData<Offset> {
  List<T> data;

  RenderGroupData(
    this.data, {
    super.id,
    super.name,
  });

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
}

abstract class RenderChildData<T, P extends RenderGroupData, A> extends RenderData<A> {
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
