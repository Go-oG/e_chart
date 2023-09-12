import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class GraphNode extends DataNode2<GraphAttr, BaseItemData, ChartSymbol> {
  GraphNode(BaseItemData data, int dataIndex)
      : super(EmptySymbol.empty, data, dataIndex, 0, GraphAttr(), LabelStyle.empty);

  @override
  bool contains(Offset offset) {
    return symbol.contains(Offset(x, y), offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, Offset(x, y));
  }

  @override
  void updateStyle(Context context, covariant GraphSeries series) {
    setSymbol(series.getSymbol(context, this), true);
  }

  ///下面是对Attr的访问封装

  double get x => attr.x;

  set x(double v) => attr.x = v;

  double get y => attr.y;

  set y(double v) => attr.y = v;

  double? get fx => attr.fx;

  set fx(double? v) => attr.fx = v;

  double? get fy => attr.fy;

  set fy(double? v) => attr.fy = v;

  double get width => attr.width;

  set width(double v) => attr.width = v;

  double get height => attr.height;

  set height(double v) => attr.height = v;

  num get r => attr.size.shortestSide / 2;

  set r(num v) => attr.size = Size.square(v * 2);

  set size(Size s) => attr.size = s;

  Size get size => attr.size;

  /// 当前X方向速度分量
  double get vx => attr.vx;

  set vx(double v) => attr.vx = v;

  /// 当前Y方向速度分量
  double get vy => attr.vy;

  set vy(double v) => attr.vy = v;

  ///权重值
  num get weight => attr.weight;

  set weight(num v) => attr.weight = v;

  String get id => data.id;

  int get index => attr.index;

  set index(int v) => attr.index = v;
}

class GraphAttr {
  int index = 0;

  ///当前X位置(中心位置)
  double x = double.nan;

  ///当前Y位置(中心位置)
  double y = double.nan;

  ///给定的固定位置
  double? fx;
  double? fy;

  ///宽高
  double width = 0;
  double height = 0;

  ///半径
  Size size = Size.zero;

  /// 当前X方向速度分量
  double vx = 0;

  /// 当前Y方向速度分量
  double vy = 0;

  ///权重值
  num weight = 0;

  GraphAttr();
}
