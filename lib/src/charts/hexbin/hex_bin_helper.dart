import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///正六边形布局
/// https://www.redblobgames.com/grids/hexagons/implementation.html#rounding
abstract class HexbinLayout extends LayoutHelper2<HexbinNode, HexbinSeries> {
  static const double _sqrt3 = 1.7320508; //sqrt(3)
  static const Orientation _pointy =
      Orientation(_sqrt3, _sqrt3 / 2.0, 0.0, 3.0 / 2.0, _sqrt3 / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 90);
  static const Orientation _flat =
      Orientation(3.0 / 2.0, 0.0, _sqrt3 / 2.0, _sqrt3, 2.0 / 3.0, 0.0, -1.0 / 3.0, _sqrt3 / 3.0, 0);

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
    var oldNodeList = nodeList;
    List<HexbinNode> newList = [];
    each(series.data, (data, p1) {
      var node = HexbinNode(
        PositiveSymbol.empty,
        data,
        p1,
        0,
        HexAttr.zero,
        series.getLabelStyle(context, data, p1, null) ?? LabelStyle.empty,
      );
      newList.add(node);
    });
    onLayout2(newList, type);
    num angleOffset = flat ? _flat.angle : _pointy.angle;
    _zeroCenter = computeZeroCenter(series, width, height);
    Size size = Size.square(radius * 1);
    each(newList, (node, i) {
      var center = hexToPixel(_zeroCenter, node.attr.hex, size);
      node.attr.center = center;
      var s = PositiveSymbol(
        r: radius,
        count: 6,
        rotate: angleOffset,
        itemStyle: AreaStyle.empty,
        borderStyle: LineStyle.empty,
      );
      node.setSymbol(s, false);
      node.updateStyle(context, series);
    });

    var an = DiffUtil.diffLayout3(
      getAnimation(type, oldNodeList.length + newList.length),
      oldNodeList,
      newList,
      (node, type) {
        Map<String, dynamic> dm = {};
        dm['rotate'] = node.symbol.rotate;
        if (type == DiffType.add) {
          dm['scale'] = 0;
        } else if (type == DiffType.remove) {
          dm['scale'] = node.symbol.scale;
        } else {
          dm['size'] = node.symbol.r;
          dm['center'] = node.attr.center;
        }
        return dm;
      },
      (node, type) {
        Map<String, dynamic> dm = {};
        dm['rotate'] = node.symbol.rotate;
        if (type == DiffType.add) {
          dm['scale'] = 1;
        } else if (type == DiffType.remove) {
          dm['scale'] = 0;
        } else {
          dm['size'] = node.symbol.r;
          dm['center'] = node.attr.center;
        }
        return dm;
      },
      (node, s, e, t, type) {
        num sr = s['rotate']!;
        num er = e['rotate']!;
        if (type == DiffType.add || type == DiffType.remove) {
          node.symbol.scale = lerpDouble(s['scale']!, e['scale']!, t)!;
        } else {
          double ss = s['size']!;
          double es = e['size']!;
          Offset sc = s['center']!;
          Offset ec = e['center']!;
          double p = es / ss;
          p = lerpDouble(1, p, t)!;
          node.symbol.scale = p;
          if (sc != ec) {
            node.attr.center = Offset.lerp(sc, ec, t)!;
          }
        }
        if (sr != er) {
          var symbol = node.symbol;
          node.setSymbol(
              PositiveSymbol(
                count: 6,
                r: symbol.r,
                rotate: lerpDouble(sr, er, t)!,
                borderStyle: symbol.borderStyle,
                itemStyle: symbol.itemStyle,
              ),
              true);
          node.symbol.scale = symbol.scale;
        }
      },
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
    );
    context.addAnimationToQueue(an);
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

  @override
  void onHandleHoverAndClickEnd(HexbinNode? oldNode, HexbinNode? newNode) {
    oldNode?.drawIndex = 0;
    newNode?.drawIndex = 100;
    if (newNode != null) {}
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    for (var diff in list) {
      diff.node.drawIndex = diff.old ? 0 : 100;
    }
    sortList(nodeList);

    List<ChartTween> tl = [];
    for (var diff in list) {
      var tween = ChartDoubleTween(props: animation);
      var node = diff.node;
      var startAttr = diff.startAttr;
      var endAttr = diff.endAttr;
      tween.addListener(() {
        var t = tween.value;
        node.itemStyle = AreaStyle.lerp(startAttr.itemStyle, endAttr.itemStyle, t);
        node.borderStyle = LineStyle.lerp(startAttr.borderStyle, endAttr.borderStyle, t);
        if (diff.old) {
          node.symbol.scale = lerpDouble(startAttr.symbolScale, 1, t)!;
        } else {
          node.symbol.scale = lerpDouble(startAttr.symbolScale, 1.1, t)!;
        }
        notifyLayoutUpdate();
      });
      tl.add(tween);
      tween.start(context, true);
    }
    each(tl, (p0, p1) {
      p0.start(context, true);
    });
  }

  @override
  Offset getTranslation() {
    return translation.toOffset();
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
