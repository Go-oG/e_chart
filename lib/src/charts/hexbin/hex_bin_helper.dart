import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

///正六边形布局
abstract class HexbinLayout extends LayoutHelper<HexbinSeries> {
  static const double _sqrt3 = 1.7320508; //sqrt(3)
  static const Orientation _pointy =
      Orientation(_sqrt3, _sqrt3 / 2.0, 0.0, 3.0 / 2.0, _sqrt3 / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 90);
  static const Orientation _flat =
      Orientation(3.0 / 2.0, 0.0, _sqrt3 / 2.0, _sqrt3, 2.0 / 3.0, 0.0, -1.0 / 3.0, _sqrt3 / 3.0, 0);
  List<HexbinNode> nodeList = [];

  ///"中心点"的重心位置
  List<SNumber> center;

  ///是否为平角在上
  bool flat;

  ///形状的大小(由外接圆半径描述)
  num radius;

  ///Hex(0,0,0)的位置
  Offset _zeroCenter = Offset.zero;

  HexbinLayout({
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.flat = true,
    this.radius = 24,
  }) : super.lazy();

  /// 子类一般情况下不应该重写改方法
  @override
  void doLayout(Rect rect, Rect globalBoxBound, LayoutType type) {
    boxBound = rect;
    this.globalBoxBound = globalBoxBound;
    var oldNodeList = this.nodeList;
    List<HexbinNode> nodeList = [];

    each(series.data, (data, p1) {
      nodeList.add(HexbinNode(data, p1, 0, HexAttr()));
    });

    onLayout2(nodeList, type);

    num angleOffset = flat ? _flat.angle : _pointy.angle;
    _zeroCenter = computeZeroCenter(series, width, height);
    Size size = Size.square(radius * 1);
    each(nodeList, (node, i) {
      var center = hexToPixel(_zeroCenter, node.attr.hex, size);
      node.attr.center = center;
      num r = series.radiusFun?.call(node.data) ?? radius;
      node.attr.shape = PositiveShape(center: center, r: r, count: 6, angleOffset: angleOffset);
    });

    this.nodeList = nodeList;
  }

  void onLayout2(List<HexbinNode> data, LayoutType type) {}

  @override
  void onLayout(LayoutType type) {
    throw ChartError("you should impl onLayout2");
  }

  @override
  SeriesType get seriesType => SeriesType.hexbin;

  ///计算Hex(0，0，0)节点的中心位置(其它节点需要根据该节点位置来计算当前位置)
  ///子类可以复写该方法实现不同的位置中心
  Offset computeZeroCenter(HexbinSeries series, num width, num height) {
    return Offset(center[0].convert(width), center[1].convert(height));
  }

  ///计算方块中心坐标(center表示Hex(0,0,0)的位置)
  ///将Hex转换为Pixel
  Offset hexToPixel(Offset center, Hex h, Size size) {
    Orientation M = flat ? _flat : _pointy;
    double x = (M.f0 * h.q + M.f1 * h.r) * size.width;
    double y = (M.f2 * h.q + M.f3 * h.r) * size.height;
    return Offset(x + center.dx, y + center.dy);
  }

  ///将Pixel转为Hex
  Hex pixelToHex(Offset offset) {
    Offset center = _zeroCenter;
    Orientation M = flat ? _flat : _pointy;
    Point pt = Point((offset.dx - center.dx) / radius, (offset.dy - center.dy) / radius);
    double qt = M.b0 * pt.x + M.b1 * pt.y;
    double rt = M.b2 * pt.x + M.b3 * pt.y;
    double st = -qt - rt;
    return Hex.round(qt, rt, st);
  }

  ///返回已center节点为中心的第N层的环节点
  static List<Hex> ring(Hex center, int N, [int ringStartIndex = 4, bool clockwise = false]) {
    if (N < 0) {
      throw FlutterError('N must >=0');
    }
    if (N == 0) {
      return [center];
    }
    List<Hex> results = [];
    var h1 = Hex.direction(ringStartIndex);
    var hex = center.add(h1.scale(N));
    for (int i = 0; i < 6; i++) {
      for (int k = 0; k < N; k++) {
        results.add(hex);
        hex = hex.neighbor2((i + (ringStartIndex - 4)) % 6);
      }
    }
    if (clockwise) {
      results = List.from(results.reversed);
    }
    return results;
  }

  ///判断节点[hex] 是否在以[center]为中心 ,N 为半径的环上
  static bool inRing(Hex center, Hex hex, int N) {
    Set<Hex> hexList = Set.from(ring(center, N));
    return hexList.contains(hex);
  }

  ///返回连接两个节点之间的线节点
  static List<Hex> line(Hex start, Hex end) {
    int N = start.distance(end);
    List<Hex> results = [];
    double step = 1.0 / max([N, 1]);
    for (int i = 0; i <= N; i++) {
      results.add(Hex.lerp(start, end, step * i));
    }
    return results;
  }

  ///将一个偏移坐标系下的位置转换为cube坐标系下的位置
  static Hex offsetCoordToHexCoord(int row, int col, {bool flat = true, bool evenLineIndent = true}) {
    int dir = evenLineIndent ? -1 : 1;
    if (flat) {
      var q = col;
      var r = (row - (col + dir * (col & 1)) / 2).toInt();
      return Hex(q, r, -q - r);
    } else {
      var q = (col - (row + dir * (row & 1)) / 2).toInt();
      var r = row;
      return Hex(q, r, -q - r);
    }
  }
}

class Orientation {
  final double f0;
  final double f1;
  final double f2;
  final double f3;
  final double b0;
  final double b1;
  final double b2;
  final double b3;
  final num angle;

  const Orientation(this.f0, this.f1, this.f2, this.f3, this.b0, this.b1, this.b2, this.b3, this.angle);
}
