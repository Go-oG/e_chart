import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 不可再分的最小绘制单元
/// 其用于极坐标系和二维坐标系下的节点位置表示
class SingleNode<T extends StackItemData, P extends StackGroupData<T>> extends DataNode<SingleAttr, WrapData<T, P>> {
  final CoordType coord;
  final ColumnNode<T, P> parentNode;

  ///标识是否是一个堆叠数据
  final bool stack;

  dynamic dynamicLabel;

  SingleNode(
    this.coord,
    this.parentNode,
    WrapData<T, P> wrap,
    this.stack,
    AreaStyle itemStyle,
    LineStyle borderStyle,
    LabelStyle labelStyle,
  ) : super(wrap, wrap.dataIndex, wrap.groupIndex, SingleAttr(), itemStyle, borderStyle, labelStyle) {
    assertCheck(coord == CoordType.grid || coord == CoordType.polar, "Coord must is Grid or Polar");
  }

  ///布局过程中使用的临时变量
  num _up = 0;

  num get up => _up;

  set up(num u) {
    _up = u;
    data.data?.stackUp = u;
  }

  num _down = 0;

  num get down => _down;

  set down(num d) {
    _down = d;
    data.data?.stackDown = d;
  }

  T? get originData => data.data;

  P get parent => data.parent;

  Arc get arc => attr.arc;

  set arc(Arc a) => attr.arc = a;

  Rect get rect => attr.rect;

  set rect(Rect r) => attr.rect = r;

  Offset get position => attr.position;

  set position(Offset o) => attr.position = o;

  int get styleIndex => data.styleIndex;

  @override
  bool contains(Offset offset) {
    return false;
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    if (coord == CoordType.grid) {
      itemStyle.drawRect(canvas, paint, rect, attr.corner);
      borderStyle.drawRect(canvas, paint, rect, attr.corner);
      return;
    }
    itemStyle.drawPath(canvas, paint, arc.toPath(true));
    borderStyle.drawPath(canvas, paint, arc.toPath(true), drawDash: true, needSplit: false);
  }

  @override
  void updateStyle(Context context, covariant StackSeries<T, P> series) {
    itemStyle = series.getAreaStyle(context, data.data, data.parent, styleIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getLineStyle(context, data.data, data.parent, styleIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data.data, data.parent, styleIndex, status) ?? LabelStyle.empty;
  }
}

class SingleAttr {
  ///只在二维坐标系下使用
  Rect rect = Rect.zero;
  Corner? corner;

  ///只在极坐标系下使用
  Arc arc = Arc();

  ///通用的节点位置，一般只有折线图和散点图使用
  Offset position = Offset.zero;
}
