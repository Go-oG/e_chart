import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import '../../component/index.dart';
import '../../core/view_state.dart';
import '../../utils/diff.dart';
import '../mixin_props.dart';
import '../text_info.dart';

///数据到绘图节点的映射
abstract class DataNode<P, D> with ViewStateProvider, ExtProps implements NodeAccessor<P, D> {
  final int dataIndex;
  final int groupIndex;
  final D data;
  late P _attr;
  P get attr => _attr;

  set attr(P a) {
    setAttr(a);
  }

  ///绘制顺序
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

  @override
  D getData() => data;

  @override
  P getAttr() {
    return attr;
  }

  @override
  void setAttr(P po) {
    _attr = po;
  }

  void onDraw(Canvas canvas, Paint paint);

  void onDrawSymbol(Canvas canvas, Paint paint) {}

  bool contains(Offset offset);
}
