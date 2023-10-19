import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

abstract class BaseData<P> with StateProvider, ExtProps {
  late final String id;
  bool show = true;
  int groupIndex = -1;
  int dataIndex = -1;

  ///绘制顺序(从小到到绘制，最大的最后绘制)
  int drawIndex = 0;

  AreaStyle itemStyle = AreaStyle.empty;
  LineStyle borderStyle = LineStyle.empty;
  TextDraw label = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero);

  List<Offset> labelLine = [];

  DataStatusChangeEvent? _dataStateChangeEvent;

  BaseData({DynamicText? label, String? id}) {
    _dataStateChangeEvent = DataStatusChangeEvent(this, status);
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    if (label != null) {
      this.label.updatePainter(text: label);
    }
  }

  P? _attr;

  P get attr => _attr!;

  P? get attrNull => _attr;

  set attr(P? a) {
    _attr = a;
  }

  void onDraw(CCanvas canvas, Paint paint);

  void onDrawSymbol(CCanvas canvas, Paint paint) {}

  bool contains(Offset offset);

  NodeAttr toAttr() {
    return NodeAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, 1);
  }

  void updateStyle(Context context, covariant ChartSeries series);

  void updateLabelPosition(Context context, covariant ChartSeries series) {}

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
      context.dispatchEvent(_dataStateChangeEvent!);
    }
    return true;
  }

  void sendStateChangeEvent(Context context) {
    if (context.hasEventListener(EventType.dataStatusChanged)) {
      context.dispatchEvent(_dataStateChangeEvent!);
    }
  }

  ///更新当前符号的大小
  void updateSymbolSize(Size size) {}

  DataType get dataType => DataType.nodeData;

  void dispose() {}

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is BaseItemData && other.id == id;
  }
}
