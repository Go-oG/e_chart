import 'dart:ui';
import 'package:e_chart/e_chart.dart';

/// 旭日图布局计算(以中心点为计算中心)
class SunburstHelper extends LayoutHelper2<SunburstData, SunburstSeries> {
  SunburstHelper(super.context, super.view, super.series);

  ///存储布局中使用的临时量
  Offset center = Offset.zero;
  num minRadius = 0;
  num maxRadius = 0;
  num radiusDiff = 0;

  SunburstData? rootNode;
  SunburstData? showRootNode;

  ///给定根节点和待布局的节点进行数据的布局
  @override
  void onLayout(LayoutType type) {
    center = viewOffset(series.center[0], series.center[1]);
    List<num> radiusList = computeRadius(view.width, view.height);
    minRadius = radiusList[0];
    maxRadius = radiusList[1];
    num radiusRange = radiusList[2];
    Map<SunburstData, SunburstData> parentMap = {};
    var newRoot = series.data;
    initData2(newRoot);
    int maxDeep = newRoot.height;
    radiusDiff = radiusRange / (maxDeep <= 0 ? 1 : maxDeep);
    newRoot.attr = buildRootArc(center, maxDeep);
    newRoot.updateLabelPosition(context, series);
    newRoot.eachBefore((tmp, index, startNode) {
      tmp.updateStyle(context, series);
      var p = tmp.parent;
      if (p != null) {
        parentMap[tmp] = p;
      }
      if (tmp.hasChild) {
        _layoutChildren(tmp, getRadiusDiff(tmp.deep, maxDeep));
      }
      return false;
    });

    var animation = getAnimation(type);
    if (animation == null) {
      rootNode = newRoot;
      showRootNode = rootNode;
      return;
    }

    ///执行动画
    Map<SunburstData, Arc> arcMap = {};
    Map<SunburstData, Arc> arcStartMap = {};
    newRoot.each((node, index, startNode) {
      arcMap[node] = node.attr;
      arcStartMap[node] = node.attr.copy(outRadius: node.attr.innerRadius);
      return false;
    });
    var tween = ChartDoubleTween(option: animation);
    tween.addStartListener(() {
      inAnimation = true;
      rootNode = newRoot;
      showRootNode = rootNode;
    });
    tween.addListener(() {
      var t = tween.value;
      newRoot.each((node, index, startNode) {
        var s = arcStartMap[node]!;
        var e = arcMap[node]!;
        node.attr = Arc.lerp(s, e, t);
        node.updateLabelPosition(context, series);
        return false;
      });
      notifyLayoutUpdate();
    });
    tween.addEndListener(() {
      inAnimation = false;
    });
    context.addAnimationToQueue([AnimationNode(tween, animation, type)]);
  }

  void initData2(SunburstData rootData) {
    if (series.sort != Sort.none) {
      rootData.sort((a, b) {
        if (series.sort == Sort.asc) {
          return a.value.compareTo(b.value);
        } else {
          return b.value.compareTo(a.value);
        }
      });
    }
    rootData.sum((p0) => p0.value);
    if (series.matchParent) {
      rootData.each((node, index, startNode) {
        if (node.hasChild) {
          node.value = 0;
        }
        return false;
      });
      rootData.sum();
    }
    rootData.computeHeight();
    rootData.setDeep(0);
    int maxDeep = rootData.height;
    rootData.each((node, index, startNode) {
      node.maxDeep = maxDeep;
      node.dataIndex = index;
      return false;
    });
  }

  void _layoutNodeIterator(SunburstData parent, int maxDeep, bool updateStyle) {
    parent.eachBefore((node, index, startNode) {
      if (updateStyle) {
        node.updateStyle(context, series);
      }
      if (node.hasChild) {
        _layoutChildren(node, getRadiusDiff(node.deep, maxDeep));
      }
      return false;
    });
  }

  void _layoutChildren(SunburstData parent, num radiusDiff) {
    if (parent.childCount == 0) {
      return;
    }
    final corner = series.corner.abs();
    final angleGap = series.angleGap.abs();
    final radiusGap = series.radiusGap.abs();
    final Arc parentArc = parent.attr;
    if (parent.childCount == 1) {
      var ir = parentArc.outRadius + radiusGap;
      parent.firstChild.attr = parentArc.copy(
        innerRadius: ir,
        outRadius: ir + radiusDiff,
        maxRadius: maxRadius,
      );
      parent.firstChild.updateLabelPosition(context, series);
      return;
    }

    bool match = series.matchParent;
    if (!match) {
      num childAllValue = sumBy<SunburstData>(parent.children, (p0) => p0.value);
      match = childAllValue >= parent.value;
    }
    int gapCount = parent.childCount - 1;
    if (match) {
      gapCount = parent.childCount;
      if (parent.parent != null) {
        gapCount -= 1;
        if (parent.parent is SunburstVirtualNode) {
          gapCount += 1;
        }
      }
    }

    final int dir = series.sweepAngle < 0 ? -1 : 1;
    final num remainAngle = parentArc.sweepAngle.abs() - angleGap * gapCount;

    num childStartAngle = parentArc.startAngle;
    if (match && (parent.parent == null || parent.parent is SunburstVirtualNode)) {
      childStartAngle += dir * angleGap / 2;
    }

    final num ir = parentArc.outRadius + radiusGap;
    final num or = ir + radiusDiff;

    each(parent.children, (ele, i) {
      double percent = ele.value / parent.value;
      if (percent > 1) {
        throw ChartError("内部异常");
      }
      double swa = remainAngle * percent;
      ele.attr = Arc(
          innerRadius: ir,
          outRadius: or,
          startAngle: childStartAngle,
          sweepAngle: swa * dir,
          cornerRadius: corner,
          padAngle: angleGap,
          maxRadius: maxRadius,
          center: center);
      ele.updateLabelPosition(context, series);
      childStartAngle += (swa + angleGap) * dir;
    });
  }

  ///构建根节点布局位置
  Arc buildRootArc(Offset center, int maxDeep) {
    num diff = radiusDiff;
    var fun = series.radiusDiffFun;
    if (fun != null) {
      diff = fun.call(0, maxDeep, radiusDiff);
    }
    num or = minRadius + diff;
    return Arc(
      innerRadius: 0,
      outRadius: or,
      startAngle: series.startAngle,
      sweepAngle: series.sweepAngle,
      center: center,
      maxRadius: maxRadius,
    );
  }

  ///构建返回节点布局属性
  Arc buildBackArc(Offset center, int deepDiff) {
    num or = minRadius;
    if (or <= 0) {
      or = getRadiusDiff(0, deepDiff);
    }
    return Arc(
      innerRadius: 0,
      outRadius: or,
      startAngle: series.startAngle,
      sweepAngle: series.sweepAngle,
      center: center,
      maxRadius: maxRadius,
    );
  }

  List<num> computeRadius(num width, num height) {
    num size = min([width, height]);
    num minRadius = 0;
    num maxRadius = 0;
    List<SNumber> radius = series.radius;
    if (radius.isEmpty) {
      maxRadius = const SNumber.percent(50).convert(size);
    } else if (radius.length == 1) {
      maxRadius = radius[0].convert(size);
    } else {
      minRadius = radius[0].convert(size);
      maxRadius = radius.last.convert(size);
    }
    if (minRadius < 0) {
      minRadius = 0;
    }
    if (maxRadius < 0) {
      maxRadius = 0;
    }
    if (maxRadius < minRadius) {
      num v = maxRadius;
      maxRadius = minRadius;
      minRadius = v;
    }
    if (maxRadius <= 0) {
      maxRadius = const SNumber.percent(50).convert(size);
    }
    return [minRadius, maxRadius, maxRadius - minRadius];
  }

  @override
  void onClick(Offset localOffset) {
    Offset offset = localOffset;
    var clickNode = findData(offset);
    if (clickNode == null || clickNode == rootNode) {
      return;
    }
    if (clickNode is SunburstVirtualNode) {
      back();
      return;
    }
    _forward(clickNode);
  }

  void _forward(SunburstData clickNode) {
    var oldBackNode = showRootNode;
    var hasBack = showRootNode is SunburstVirtualNode;
    var animation = getAnimation(LayoutType.update, -1);
    if (hasBack && oldBackNode != null) {
      oldBackNode.clear();
      clickNode.parent = null;
      oldBackNode.add(clickNode);
      oldBackNode.value = clickNode.value;

      var oldE = oldBackNode.attr;
      var s = clickNode.attr;
      var ir = oldE.outRadius + series.radiusGap;
      var e = Arc(
        innerRadius: ir,
        outRadius: ir + getRadiusDiff(1, clickNode.height + 1),
        center: center,
        startAngle: series.startAngle,
        sweepAngle: series.sweepAngle,
        maxRadius: maxRadius,
      );
      if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
        clickNode.attr = e;
        clickNode.updateLabelPosition(context, series);
        _layoutNodeIterator(clickNode, clickNode.height + 1, false);
        notifyLayoutUpdate();
        return;
      }

      var tween = ChartDoubleTween(option: animation);
      tween.addListener(() {
        var t = tween.value;
        clickNode.attr = Arc.lerp(s, e, t);
        clickNode.updateLabelPosition(context, series);
        _layoutNodeIterator(clickNode, clickNode.height + 1, false);
        notifyLayoutUpdate();
      });
      tween.start(context, true);
      return;
    }

    ///拆分动画
    ///返回节点
    var be = buildBackArc(center, clickNode.height + 1);
    var bs = be.copy(outRadius: be.innerRadius);
    var bn = SunburstVirtualNode(clickNode, bs);

    var cs = clickNode.attr;
    var ir = be.outRadius + series.radiusGap;
    var ce = Arc(
      startAngle: series.startAngle,
      sweepAngle: series.sweepAngle,
      innerRadius: ir,
      outRadius: ir + getRadiusDiff(1, clickNode.height + 1),
      center: center,
      maxRadius: maxRadius,
    );
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      bn.attr = be;
      bn.updateLabelPosition(context, series);
      clickNode.attr = ce;
      clickNode.updateLabelPosition(context, series);
      _layoutNodeIterator(clickNode, clickNode.height + 1, false);
      showRootNode = bn;
      notifyLayoutUpdate();
      return;
    }

    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      var t = tween.value;
      bn.attr = Arc.lerp(bs, be, t);
      bn.updateLabelPosition(context, series);

      clickNode.attr = Arc.lerp(cs, ce, t);
      clickNode.updateLabelPosition(context, series);
      _layoutNodeIterator(clickNode, clickNode.height + 1, false);
      notifyLayoutUpdate();
    });
    showRootNode = bn;
    tween.start(context, true);
  }

  void back() {
    var bn = showRootNode;
    showRootNode = null;
    if (bn == null || bn is! SunburstVirtualNode) {
      return;
    }
    var first = bn.firstChild;
    first.parent = null;

    Map<SunburstData, Arc> oldArcMap = {};
    first.each((node, index, startNode) {
      oldArcMap[node] = node.attr;
      return false;
    });

    var parentData = first.parent?.parent;
    SunburstData parentNode;
    if (parentData == null) {
      parentNode = rootNode!;
      bn = rootNode!;
      first.parent = bn;
    } else {
      parentData = first.parent!;
      parentNode = parentData.parent!;
      parentNode.parent = null;
      bn = SunburstVirtualNode(parentNode, buildBackArc(center, parentNode.height + 1));
    }
    bn.updateLabelPosition(context, series);
    _layoutNodeIterator(bn, parentNode.height + 1, false);

    var animation = getAnimation(LayoutType.update, -1);
    if (animation == null) {
      showRootNode = bn;
      notifyLayoutUpdate();
      return;
    }

    Map<SunburstData, Arc> arcMap = {};
    parentNode.each((node, index, startNode) {
      var arc = node.attr;
      arcMap[node] = arc;
      if (!oldArcMap.containsKey(node)) {
        oldArcMap[node] = arc.copy(outRadius: arc.innerRadius, maxRadius: maxRadius);
      }
      return false;
    });
    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      var t = tween.value;
      parentNode.each((node, index, startNode) {
        var e = arcMap[node]!;
        var s = oldArcMap[node]!;
        node.attr = Arc.lerp(s, e, t);
        node.updateLabelPosition(context, series);
        return false;
      });
      notifyLayoutUpdate();
    });
    tween.start(context, true);
    showRootNode = bn;
  }

  @override
  void onHandleHoverAndClick(Offset offset, bool click) {
    var sn = showRootNode;
    if (sn == null) {
      return;
    }
    var hoverNode = findData(offset);
    var oldNode = oldHoverData;
    oldHoverData = hoverNode;
    if (hoverNode == oldNode) {
      if (hoverNode != null && hoverNode is! SunburstVirtualNode) {
        //   sendHoverEvent(offset, hoverNode);
      }
      return;
    }
    List<NodeDiff<SunburstData>> nl = [];
    if (oldNode != null) {
      var attr = oldNode.toAttr();
      oldNode.removeState(ViewState.hover);
      oldNode.updateStyle(context, series);
      nl.add(NodeDiff(oldNode, attr, oldNode.toAttr(), true));
      if (oldNode is! SunburstVirtualNode) {
        sendHoverEndEvent(oldNode);
      }
    }
    if (hoverNode != null) {
      var attr = hoverNode.toAttr();
      hoverNode.addState(ViewState.hover);
      hoverNode.updateStyle(context, series);
      nl.add(NodeDiff(hoverNode, attr, hoverNode.toAttr(), false));
      if (hoverNode is! SunburstVirtualNode) {
        sendHoverEvent(offset, hoverNode);
      }
    }
    var animation = getAnimation(LayoutType.update, getAnimatorCountLimit());
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      notifyLayoutUpdate();
      return;
    }
    onRunUpdateAnimation(nl, animation);
  }

  num getRadiusDiff(int deep, int maxDeep) {
    num rd = radiusDiff;
    if (series.radiusDiffFun != null) {
      rd = series.radiusDiffFun!.call(deep, maxDeep, radiusDiff);
    }
    return rd;
  }

  @override
  SunburstData? findData(Offset offset, [bool overlap = false]) {
    return showRootNode?.find((node, index, startNode) {
      Arc arc = node.attr;
      return arc.contains(offset);
    });
  }
}
