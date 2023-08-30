import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

class ThemeRiverHelper extends LayoutHelper<ThemeRiverSeries> {
  num maxTransX = 0, maxTransY = 0;
  List<ThemeRiverNode> nodeList = [];
  double animatorPercent = 1;

  ThemeRiverHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    tx = ty = 0;
    List<ThemeRiverNode> newList = [];
    each(series.data, (d, i) {
      ThemeRiverNode node = ThemeRiverNode(d, i, 0, ThemeRiverAttr.empty);
      newList.add(node);
    });
    var animation = series.animation;
    if (animation == null || type == LayoutType.none) {
      nodeList = newList;
      return;
    }
    layoutNode(newList);

    if (type != LayoutType.layout) {
      nodeList = newList;
      animatorPercent = 1;
      return;
    }

    ChartDoubleTween tween = ChartDoubleTween(props: animation);
    tween.startListener = () {
      nodeList = newList;
    };
    tween.addListener(() {
      animatorPercent = tween.value;
      notifyLayoutUpdate();
    });
    context.addAnimationToQueue([AnimationNode(tween, animation, type)]);
  }

  void layoutNode(List<ThemeRiverNode> newList) {
    final List<List<_InnerNode>> innerNodeList = [];
    for (var ele in newList) {
      List<_InnerNode> tmp = [];
      for (var e2 in ele.data.data) {
        tmp.add(_InnerNode(e2.value));
      }
      if (tmp.isNotEmpty) {
        innerNodeList.add(tmp);
      }
    }
    var base = _computeBaseline(innerNodeList);
    List<double> baseLine = base['y0'];
    Direction direction = series.direction;

    double tw = (direction == Direction.horizontal ? height : width) * 0.95;
    double ky = tw / base['max'];

    int n = innerNodeList.length;
    int m = innerNodeList[0].length;
    tw = direction == Direction.horizontal ? width : height;
    double iw = m <= 1 ? 0 : tw / (m - 1);
    if (m > 1 && series.minInterval != null) {
      double minw = series.minInterval!.convert(tw);
      if (iw < minw) {
        iw = minw;
      }
    }
    double baseY0;
    for (int j = 0; j < m; ++j) {
      baseY0 = baseLine[j] * ky;
      innerNodeList[0][j].setItemLayout(0, iw * j, baseY0, innerNodeList[0][j].value * ky);
      for (int i = 1; i < n; ++i) {
        baseY0 += innerNodeList[i - 1][j].value * ky;
        innerNodeList[i][j].setItemLayout(i, iw * j, baseY0, innerNodeList[i][j].value * ky);
      }
    }

    for (int j = 0; j < innerNodeList.length; j++) {
      ThemeRiverNode node = newList[j];
      var ele = innerNodeList[j];
      List<Offset> pList = [];
      List<Offset> pList2 = [];
      for (int i = 0; i < ele.length; i++) {
        if (direction == Direction.horizontal) {
          pList.add(Offset(ele[i].x, ele[i].py0));
          pList2.add(Offset(ele[i].x, ele[i].py + ele[i].py0));
        } else {
          pList.add(Offset(ele[i].py0, ele[i].x));
          pList2.add(Offset(ele[i].py + ele[i].py0, ele[i].x));
        }
      }
      node._buildPath(pList, pList2, series.smooth, series.direction);
    }
    //   adjust(newList, width, height);
  }

  @override
  SeriesType get seriesType => SeriesType.themeriver;

  Map<String, dynamic> _computeBaseline(List<List<_InnerNode>> data) {
    int layerNum = data.length;
    int pointNum = data[0].length;
    List<double> sums = [];
    double max = 0;

    ///按照时间序列 计算并保存每个序列值和，且和全局最大序列值和进行比较保留最大的
    for (int i = 0; i < pointNum; ++i) {
      double temp = 0;
      for (int j = 0; j < layerNum; ++j) {
        temp += data[j][i].value;
      }
      if (temp > max) {
        max = temp;
      }
      sums.add(temp);
    }

    ///计算每个序列与最大序列值差值的一半
    List<double> y0 = List.filled(pointNum, 0);
    for (int k = 0; k < pointNum; ++k) {
      y0[k] = (max - sums[k]) / 2;
    }

    max = 0;
    for (int l = 0; l < pointNum; ++l) {
      double sum = sums[l] + y0[l];
      if (sum > max) {
        max = sum;
      }
    }

    return {'y0': y0, 'max': max};
  }

  @override
  void onHoverMove(Offset localOffset) {
    handleHover(localOffset, false);
  }

  @override
  void onHoverStart(Offset localOffset) {
    handleHover(localOffset, false);
  }

  @override
  void onHoverEnd() {
    _oldHoverNode?.removeState(ViewState.hover);
    _oldHoverNode?.removeState(ViewState.selected);
  }

  @override
  void onClick(Offset localOffset) {
    handleHover(localOffset, true);
  }

  ThemeRiverNode? _oldHoverNode;
  double tx = 0;
  double ty = 0;

  void handleHover(Offset local, bool click) {
    var nodeList = this.nodeList;
    Offset offset = local.translate(-tx, -ty);
    var clickNode = findNode(offset);
    if (clickNode == _oldHoverNode) {
      if (clickNode != null) {
        sendHoverEvent(offset, clickNode);
      }
      return;
    }
    var oldNode = _oldHoverNode;
    _oldHoverNode = clickNode;
    oldNode?.removeStates([ViewState.hover, ViewState.selected]);
    clickNode?.addStates([ViewState.hover, ViewState.selected]);
    if (clickNode != null) {
      click ? sendClickEvent(offset, clickNode) : sendHoverEvent(offset, clickNode);
    }
    if (oldNode != null) {
      sendHoverEndEvent(oldNode);
    }
    oldNode?.attr.index = 0;
    clickNode?.attr.index = 100;

    ChartDoubleTween tween = ChartDoubleTween(props: series.animation!);
    AreaStyleTween? selectTween;
    AreaStyleTween? unselectTween;
    if (clickNode != null && clickNode.areaStyle != null) {
      selectTween = AreaStyleTween(clickNode.areaStyle!, getStyle(clickNode));
    }
    if (oldNode != null && oldNode.areaStyle != null) {
      unselectTween = AreaStyleTween(oldNode.areaStyle!, getStyle(oldNode));
    }
    nodeList.sort((a, b) {
      return a.attr.index.compareTo(b.attr.index);
    });
    tween.addListener(() {
      double p = tween.value;
      if (selectTween != null) {
        clickNode!.areaStyle = selectTween.safeGetValue(p);
      }
      if (unselectTween != null) {
        oldNode!.areaStyle = unselectTween.safeGetValue(p);
      }
      notifyLayoutUpdate();
    });
    tween.start(context);
  }

  ThemeRiverNode? findNode(Offset offset) {
    for (var node in nodeList) {
      if (node.attr.area.toPath(true).contains(offset)) {
        return node;
      }
    }
    return null;
  }

  AreaStyle getStyle(ThemeRiverNode node) {
    var fun = series.areaStyleFun;
    if (fun != null) {
      return fun.call(node.data, node.dataIndex, node.status);
    }
    int index = node.dataIndex;
    var color = context.option.theme.getColor(index);
    return AreaStyle(color: color).convert(node.status);
  }

  LabelStyle? getLabelStyle(ThemeRiverNode node) {
    var fun = series.labelStyleFun;
    if (fun != null) {
      return fun.call(node.data, node.dataIndex, node.status);
    }
    var theme = context.option.theme;
    return theme.getLabelStyle()?.convert(node.status);
  }
}

class ThemeRiverNode extends DataNode<ThemeRiverAttr, GroupData> {
  ThemeRiverNode(super.data, super.dataIndex, super.groupIndex, super.attr);

  void _buildPath(List<Offset> pList, List<Offset> pList2, bool smooth, Direction direction) {
    Area area;
    if (direction == Direction.vertical) {
      area = Area.vertical(pList, pList2, upSmooth: smooth, downSmooth: smooth);
    } else {
      area = Area(pList, pList2, upSmooth: smooth, downSmooth: smooth);
    }

    List<Offset> polygonList = [];
    polygonList.addAll(pList);
    polygonList.addAll(pList2.reversed);

    Offset o1 = polygonList.first;
    Offset o2 = polygonList.last;
    TextDrawInfo config;
    if (direction == Direction.horizontal) {
      Offset offset = Offset(o1.dx, (o1.dy + o2.dy) * 0.5);
      config = TextDrawInfo(offset, align: Alignment.centerLeft);
    } else {
      Offset offset = Offset((o1.dx + o2.dx) / 2, o1.dy);
      config = TextDrawInfo(offset, align: Alignment.topCenter);
    }
    attr = ThemeRiverAttr(polygonList, area, config);
  }

  Path get drawPath => attr.area.toPath(true);
}

class ThemeRiverAttr {
  static final empty = ThemeRiverAttr([], Area([], []), null);
  final List<Offset> polygonList;
  final Area area;
  final TextDrawInfo? textConfig;
  int index = 0;

  ThemeRiverAttr(this.polygonList, this.area, this.textConfig);
}

class _InnerNode {
  final num value;
  int index = 0;
  double x = 0;
  double py = 0;
  double py0 = 0;

  _InnerNode(this.value);

  void setItemLayout(int index, double px, double py0, double py) {
    this.index = index;
    x = px;
    this.py = py;
    this.py0 = py0;
  }
}
