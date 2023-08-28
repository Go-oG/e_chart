import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///正六边形布局
/// https://www.redblobgames.com/grids/hexagons/implementation.html#rounding
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
    var oldNodeList = nodeList;
    List<HexbinNode> newList = [];
    each(series.data, (data, p1) {
      newList.add(HexbinNode(data, p1, 0, HexAttr.zero));
    });

    onLayout2(newList, type);

    num angleOffset = flat ? _flat.angle : _pointy.angle;
    _zeroCenter = computeZeroCenter(series, width, height);
    Size size = Size.square(radius * 1);
    each(newList, (node, i) {
      var center = hexToPixel(_zeroCenter, node.attr.hex, size);
      node.attr.center = center;
      num r = series.radiusFun?.call(node.data) ?? radius;
      node.attr.shape = PositiveShape(center: center, r: r, count: 6, angleOffset: angleOffset);
    });
    var animation = series.animation;
    if (animation == null) {
      nodeList = newList;
      return;
    }
    var an = DiffUtil.diffLayout2<HexAttr, ItemData, HexbinNode>(
      animation,
      oldNodeList,
      newList,
      (data, node, add) {
        num angleOffset = flat ? _flat.angle : _pointy.angle;
        var attr = HexAttr(node.attr.hex);
        attr.center = node.attr.center;
        attr.shape = PositiveShape(center: node.attr.center, count: 6, r: 0, angleOffset: angleOffset);
        return attr;
      },
      (s, e, t, type) {
        var attr = e.copy(alpha: 1);
        attr.center = Offset.lerp(s.center, e.center, t)!;
        attr.shape = PositiveShape.lerp(s.shape, e.shape, t);
        return attr;
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
  void onClick(Offset localOffset) {
    handleHoverAndClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    handleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    handleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverEnd() {
    var node = _oldNode;
    _oldNode = null;
    if (node == null) {
      return;
    }
    sendHoverOutEvent(node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
    _runUpdateAnimation([node], [], series.animation);
  }

  HexbinNode? _oldNode;

  void handleHoverAndClick(Offset offset, bool click) {
    Offset scroll = getScroll();
    offset = offset.translate(-scroll.dx, -scroll.dy);
    var clickNode = findNode(offset);
    if (clickNode == _oldNode) {
      return;
    }

    var old = _oldNode;
    _oldNode = clickNode;

    List<HexbinNode> oldList = [];
    if (old != null) {
      oldList.add(old);
      sendHoverOutEvent(old.data, dataIndex: old.dataIndex, groupIndex: old.groupIndex);
    }
    List<HexbinNode> newList = [];
    if (clickNode != null) {
      newList.add(clickNode);
      if (click) {
        sendClickEvent(offset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
      } else {
        sendHoverInEvent(offset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
      }
    }
    _runUpdateAnimation(oldList, newList, series.animation);
  }

  void _runUpdateAnimation(List<HexbinNode> oldList, List<HexbinNode> newList, AnimationAttrs? animation) {
    for (var node in oldList) {
      node.removeState(ViewState.selected);
      node.removeState(ViewState.hover);
    }
    for (var node in newList) {
      node.addState(ViewState.selected);
      node.addState(ViewState.hover);
    }

    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      notifyLayoutUpdate();
      return;
    }

    DiffUtil.diffUpdate<HexAttr, ItemData, HexbinNode>(
      context,
      animation,
      oldList,
      newList,
      (data, node, isOld) {
        return node.attr.copy(alpha: 0);
      },
      (s, e, t) {
        return e.copy(alpha: lerpDouble(s.alpha, e.alpha, t));
      },
      () {
        notifyLayoutUpdate();
      },
    );
  }

  ///获取滚动偏移量
  ///是可以有正负的
  Offset getScroll() {
    return Offset.zero;
  }

  HexbinNode? findNode(Offset offset) {
    for (var node in nodeList) {
      if (node.attr.shape.contains(offset)) {
        return node;
      }
    }
    return null;
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
