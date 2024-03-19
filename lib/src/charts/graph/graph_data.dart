import 'dart:ui';
import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/model/layout_result.dart';

class GraphData extends RenderData2<GraphAttr, ChartSymbol> {
  GraphItemData data;

  GraphData(
    this.data, {
    super.id,
    super.name,
  }) {
    symbol = EmptySymbol.empty;
  }

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

  num get r => m.min(attr.width, attr.height) / 2;

  set r(num v) => attr.width = attr.height = v * 2;

  set size(Size s) {
    attr.width = s.width;
    attr.height = s.height;
  }

  Size get size => Size(attr.width, attr.height);

  Offset get center => Offset(x, y);

  /// 当前X方向速度分量
  double get vx => attr.vx;

  set vx(double v) => attr.vx = v;

  /// 当前Y方向速度分量
  double get vy => attr.vy;

  set vy(double v) => attr.vy = v;

  ///权重值
  num get weight => attr.weight;

  set weight(num v) => attr.weight = v;

  int get index => attr.index;

  set index(int v) => attr.index = v;

  @override
  GraphAttr initAttr() => GraphAttr();
}

class GraphAttr extends LayoutResult {
  int index = 0;

  ///当前X位置(中心位置)
  double x = double.nan;

  ///当前Y位置(中心位置)
  double y = double.nan;

  ///给定的固定位置
  double? fx;
  double? fy;

  /// 当前X方向速度分量
  double vx = 0;

  /// 当前Y方向速度分量
  double vy = 0;

  ///权重值
  num weight = 0;

  GraphAttr();
}

class EdgeData extends RenderData<EdgeAttr> {
  final EdgeItemData data;

  EdgeData(this.data, int dataIndex, {super.id});

  GraphData get source => data.source;

  GraphData get target => data.target;

  @override
  bool contains(Offset offset) {
    return Segment(source.center, target.center).contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    borderStyle.drawPolygon(canvas, paint, points);
  }

  @override
  void updateStyle(Context context, covariant GraphSeries series) {
    borderStyle = series.getBorderStyle(context, source, target, status);
  }

  double get x => attr.x;

  double get y => attr.y;

  double get width => attr.width;

  double get height => attr.height;

  set x(double v) => attr.x = v;

  set y(double v) => attr.y = v;

  set width(double v) => attr.width = v;

  set height(double v) => attr.height = v;

  num get minLen => data.minLen;

  num get weight => data.weight;

  num get labelOffset => data.labelOffset;

  LabelPosition get labelPos => data.labelPos;

  List<Offset> get points => attr.points;

  set points(List<Offset> ol) => attr.points = ol;

  int get index => attr.index;

  set index(int i) => attr.index = i;

  @override
  EdgeAttr initAttr() => EdgeAttr();
}

class EdgeAttr extends LayoutResult {
  int index = 0;
  double x = 0;
  double y = 0;
  List<Offset> points = [];
}

class GraphItemData extends BaseItemData {
  ///固定的位置
  double? fx;
  double? fy;

  ///权重值
  double weight = 1;

  ///组id?
  String? groupId;

  num? width;
  num? height;

  GraphItemData({
    this.fx,
    this.fy,
    this.weight = 1,
    this.groupId,
    super.id,
    super.name,
  });
}

class EdgeItemData extends BaseItemData {
  final GraphData source;
  final GraphData target;

  num minLen;
  num labelOffset;
  LabelPosition labelPos;
  num weight = 1;

  EdgeItemData(
    this.source,
    this.target, {
    this.labelOffset = 0,
    this.minLen = 1,
    this.weight = 1,
    this.labelPos = LabelPosition.center,
    super.id,
    super.name,
  });
}
