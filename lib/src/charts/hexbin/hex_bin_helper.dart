import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///正六边形布局
/// https://www.redblobgames.com/grids/hexagons/implementation.html#rounding
class HexbinHelper extends LayoutHelper2<HexbinNode, HexbinSeries> {
  static const double _sqrt3 = 1.7320508; //sqrt(3)
  static const _Orientation _pointy =
      _Orientation(_sqrt3, _sqrt3 / 2.0, 0.0, 3.0 / 2.0, _sqrt3 / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 90);
  static const _Orientation _flat =
      _Orientation(3.0 / 2.0, 0.0, _sqrt3 / 2.0, _sqrt3, 2.0 / 3.0, 0.0, -1.0 / 3.0, _sqrt3 / 3.0, 0);

  ///Hex(0,0,0)的位置
  Offset _zeroCenter = Offset.zero;

  HexbinHelper(super.context, super.view, super.series);

  bool flat = false;
  num radius = 0;

  @override
  void onLayout(LayoutType type) {
    var oldNodeList = nodeList;
    List<HexbinNode> newList = convertDataToNode(series.data);

    flat = series.flat;
    radius = series.radius;

    var params = HexbinLayoutParams(series, width, height, radius.toDouble(), series.flat);
    var hexLayout = series.layout;
    hexLayout.onLayout(newList, type, params);
    flat = params.flat;

    ///坐标转换
    final angleOffset = flat ? _flat.angle : _pointy.angle;
    _zeroCenter = hexLayout.computeZeroCenter(params);
    final size = Size.square(radius * 1);
    each(newList, (node, i) {
      var center = hexToPixel(_zeroCenter, node.attr.hex, size);
      node.attr.center = center;
      var s = PositiveSymbol(
          r: series.radius, count: 6, fixRotate: 0, itemStyle: AreaStyle.empty, borderStyle: LineStyle.empty);
      s.rotate = angleOffset;

      node.setSymbol(s, false);
      node.updateStyle(context, series);
    });
    var an = DiffUtil.diffLayout3(
      getAnimation(type, oldNodeList.length + newList.length),
      oldNodeList,
      newList,
      (node, type) {
        Map<String, dynamic> dm = {};
        dm['center'] = node.attr.center;
        dm['rotate'] = node.symbol.rotate;
        dm['scale'] = type == DiffType.add ? 0 : node.symbol.scale;
        return dm;
      },
      (node, type) {
        Map<String, dynamic> dm = {};
        dm['center'] = node.attr.center;
        dm['rotate'] = node.symbol.rotate;
        dm['scale'] = type == DiffType.remove ? 0 : 1;
        return dm;
      },
      (node, s, e, t, type) {
        Offset sc = s['center']!;
        Offset ec = e['center']!;
        num sr = s['rotate']!;
        num er = e['rotate']!;
        double ss = s['scale']!;
        double es = e['scale']!;
        node.attr.center = sc == ec ? ec : Offset.lerp(sc, ec, t)!;
        node.symbol.rotate = lerpDouble(sr, er, t)!;
        node.symbol.scale = lerpDouble(ss, es, t)!;
      },
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
      () => inAnimation = true,
      () => inAnimation = false,
    );
    context.addAnimationToQueue(an);
  }

  List<HexbinNode> convertDataToNode(List<ItemData> data) {
    List<HexbinNode> newList = [];
    each(data, (data, p1) {
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
    return newList;
  }

  ///计算方块中心坐标(center表示Hex(0,0,0)的位置)
  ///将Hex转换为Pixel
  Offset hexToPixel(Offset center, Hex h, Size size) {
    _Orientation M = flat ? _flat : _pointy;
    double x = (M.f0 * h.q + M.f1 * h.r) * size.width;
    double y = (M.f2 * h.q + M.f3 * h.r) * size.height;
    return Offset(x + center.dx, y + center.dy);
  }

  ///将Pixel转为Hex
  Hex pixelToHex(Offset offset) {
    Offset center = _zeroCenter;
    _Orientation M = flat ? _flat : _pointy;
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
      var tween = ChartDoubleTween(option: animation);
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
    return view.translation;
  }
}

class _Orientation {
  final double f0;
  final double f1;
  final double f2;
  final double f3;
  final double b0;
  final double b1;
  final double b2;
  final double b3;
  final double angle;

  const _Orientation(this.f0, this.f1, this.f2, this.f3, this.b0, this.b1, this.b2, this.b3, this.angle);
}
