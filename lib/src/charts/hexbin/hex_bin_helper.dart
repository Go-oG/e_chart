import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///正六边形布局
/// https://www.redblobgames.com/grids/hexagons/implementation.html#rounding
class HexBinHelper extends LayoutHelper2<HexBinData, HexbinSeries> {
  static const double _sqrt3 = 1.7320508; //sqrt(3)
  static const _Orientation _pointy =
      _Orientation(_sqrt3, _sqrt3 / 2.0, 0.0, 3.0 / 2.0, _sqrt3 / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 90);
  static const _Orientation _flat =
      _Orientation(3.0 / 2.0, 0.0, _sqrt3 / 2.0, _sqrt3, 2.0 / 3.0, 0.0, -1.0 / 3.0, _sqrt3 / 3.0, 0);

  ///Hex(0,0,0)的位置
  Offset _zeroCenter = Offset.zero;
  bool flat = false;
  double radius = 0;
  List<HexBinData> showNodeList = [];

  ///用于加速节点查找
  late final RBush<HexBinData> _rBush;

  HexBinHelper(super.context, super.view, super.series) {
    _rBush = RBush(
      (p0) => p0.center.dx - radius,
      (p0) => p0.center.dy - radius,
      (p0) => p0.center.dx + radius,
      (p0) => p0.center.dy + radius,
    );
  }

  @override
  void onLayout(LayoutType type) {
    var oldNodeList = dataSet;
    var newList = [...series.data];
    initDataIndexAndStyle(newList);
    var an = DiffUtil.diff<HexBinData>(
      getAnimation(type, series.data.length),
      oldNodeList,
      newList,
      (dataList) => layoutData(dataList, type),
      (data, type) {
        Map<String, dynamic> dm = {};
        dm['center'] = data.center;
        dm['rotate'] = data.rotate;
        dm['scale'] = type == DiffType.add ? 0 : data.scale;
        return dm;
      },
      (data, type) {
        Map<String, dynamic> dm = {};
        dm['center'] = data.center;
        dm['rotate'] = data.rotate;
        dm['scale'] = type == DiffType.remove ? 0 : 1;
        return dm;
      },
      (data, s, e, t, type) {
        Offset sc = s['center']!;
        Offset ec = e['center']!;
        num sr = s['rotate']!;
        num er = e['rotate']!;
        num ss = s['scale']!;
        num es = e['scale']!;
        data.center = lerpOffset(sc, ec, t);
        data.rotate = lerpDouble(sr, er, t)!;
        data.scale = lerpDouble(ss, es, t)!;
        data.updateLabelPosition(context, series);
      },
      (dataList, t) {
        dataSet = dataList;
        updateShowNodeList(dataList);
        notifyLayoutUpdate();
      },
      onStart: () {
        inAnimation = true;
      },
      onEnd: () {
        _rBush.clear();
        _rBush.addAll(dataSet);
        var sRect = getViewPortRect().inflate(radius * 2);
        showNodeList = _rBush.search2(sRect);
        inAnimation = false;
      },
    );
    context.addAnimationToQueue(an);
  }

  void layoutData(List<HexBinData> dataList, LayoutType type) {
    flat = series.flat;
    radius = series.radius.toDouble();
    var params = HexbinLayoutParams(series, view.width, view.height, radius.toDouble(), series.flat);
    var hexLayout = series.layout;
    hexLayout.onLayout(dataList, type, params);
    flat = params.flat;

    ///坐标转换
    final angleOffset = flat ? _flat.angle : _pointy.angle;
    _zeroCenter = hexLayout.computeZeroCenter(params);
    final size = Size.square(radius * 1);
    var sPath = PositiveShape(r: radius, count: 6).toPath();
    each(dataList, (data, i) {
      var center = hexToPixel(_zeroCenter, data.hex, size);
      data.center = center;
      data.rotate = angleOffset;
      data.scale = 1;
      data.shapePath = sPath;
      data.updateStyle(context, series);
      data.updateLabelPosition(context, series);
    });
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
  void onHandleHoverAndClickEnd(HexBinData? oldNode, HexBinData? newNode) {
    oldNode?.drawIndex = 0;
    newNode?.drawIndex = 100;
    if (newNode != null) {}
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    for (var diff in list) {
      diff.data.drawIndex = diff.old ? 0 : 100;
    }
    sortList(showNodeList);

    List<ChartTween> tl = [];
    for (var diff in list) {
      var tween = ChartDoubleTween(option: animation);
      var node = diff.data;
      var startAttr = diff.startAttr;
      var endAttr = diff.endAttr;
      tween.addListener(() {
        var t = tween.value;
        node.itemStyle = AreaStyle.lerp(startAttr.itemStyle, endAttr.itemStyle, t);
        node.borderStyle = LineStyle.lerp(startAttr.borderStyle, endAttr.borderStyle, t);
        if (diff.old) {
          node.scale = lerpDouble(startAttr.symbolScale, 1, t)!;
        } else {
          node.scale = lerpDouble(startAttr.symbolScale, 1.1, t)!;
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
  int getAnimatorCountLimit() {
    return showNodeList.length;
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    var sRect = getViewPortRect().inflate(radius * 2);
    showNodeList = _rBush.search2(sRect);
    notifyLayoutUpdate();
  }

  @override
  HexBinData? findData(Offset offset, [bool overlap = false]) {
    var rect = Rect.fromCircle(center: offset, radius: radius);
    var result = _rBush.search2(rect);
    result.sort((a, b) {
      return b.drawIndex.compareTo(a.drawIndex);
    });
    for (var node in result) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }

  void updateShowNodeList(List<HexBinData> nodeList) {
    List<HexBinData> nl = [];
    var sRect = getViewPortRect();
    each(nodeList, (node, p1) {
      if (sRect.overlapCircle(node.center, radius)) {
        nl.add(node);
      }
    });
    showNodeList = nl;
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
