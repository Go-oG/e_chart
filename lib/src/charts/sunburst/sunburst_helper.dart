import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import 'sunburst_node.dart';

/// 旭日图布局计算(以中心点为计算中心)
class SunburstHelper extends LayoutHelper2<SunburstNode, SunburstSeries> {
  SunburstHelper(super.context, super.view, super.series);

  ///存储布局中使用的临时量
  Offset center = Offset.zero;
  num minRadius = 0;
  num maxRadius = 0;
  num radiusDiff = 0;

  SunburstNode? rootNode;
  SunburstNode? showRootNode;

  Map<TreeData, SunburstNode> _nodeMap = {};

  ///给定根节点和待布局的节点进行数据的布局
  @override
  void onLayout(LayoutType type) {
    center = Offset(series.center[0].convert(width), series.center[1].convert(height));
    List<num> radiusList = computeRadius(width, height);
    minRadius = radiusList[0];
    maxRadius = radiusList[1];
    num radiusRange = radiusList[2];
    Map<TreeData, SunburstNode> nodeMap = {};
    Map<TreeData, TreeData> parentMap = {};
    SunburstNode newRoot = convertData(series.data);
    nodeMap[series.data] = newRoot;
    int maxDeep = newRoot.height;
    radiusDiff = radiusRange / (maxDeep <= 0 ? 1 : maxDeep);
    newRoot.attr = SunburstAttr(buildRootArc(center, maxDeep));
    newRoot.updateTextPosition(series);
    newRoot.eachBefore((tmp, index, startNode) {
      tmp.updateStyle(context, series);
      nodeMap[tmp.data] = tmp;
      var p = tmp.data.parent;
      if (p != null) {
        parentMap[tmp.data] = p;
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
      _nodeMap = nodeMap;
      return;
    }

    ///执行动画
    Map<SunburstNode, Arc> arcMap = {};
    Map<SunburstNode, Arc> arcStartMap = {};
    newRoot.each((node, index, startNode) {
      arcMap[node] = node.attr.arc;
      arcStartMap[node] = node.attr.arc.copy(outRadius: node.attr.arc.innerRadius);
      return false;
    });
    var tween = ChartDoubleTween(option: animation);
    tween.addStartListener(() {
      inAnimation = true;
      rootNode = newRoot;
      showRootNode = rootNode;
      _nodeMap = nodeMap;
    });
    tween.addListener(() {
      var t = tween.value;
      newRoot.each((node, index, startNode) {
        var s = arcStartMap[node]!;
        var e = arcMap[node]!;
        node.attr.arc = Arc.lerp(s, e, t);
        node.updateTextPosition(series);
        return false;
      });
      notifyLayoutUpdate();
    });
    tween.addEndListener(() {
      inAnimation = false;
    });
    context.addAnimationToQueue([AnimationNode(tween, animation, type)]);
  }

  SunburstNode convertData(TreeData rootData) {
    int index = 0;
    SunburstNode root = toTree<TreeData, SunburstAttr, SunburstNode>(
      series.data,
      (p0) => p0.children,
      (p0, p1) {
        p1.parent = p0?.data;
        index++;
        return SunburstNode(p0, p1, index - 1, value: p1.value);
      },
      sort: (a, b) {
        if (series.sort == Sort.none) {
          return 0;
        }
        if (series.sort == Sort.asc) {
          return a.data.value.compareTo(b.data.value);
        } else {
          return b.data.value.compareTo(a.data.value);
        }
      },
    );
    root.sum((p0) => p0.data.value);
    if (series.matchParent) {
      root.each((node, index, startNode) {
        if (node.hasChild) {
          node.value = 0;
        }
        return false;
      });
      root.sum();
    }
    root.computeHeight();
    int maxDeep = root.height;
    root.each((node, index, startNode) {
      node.maxDeep = maxDeep;
      return false;
    });
    return root;
  }

  void _layoutNodeIterator(SunburstNode parent, int maxDeep, bool updateStyle) {
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

  void _layoutChildren(SunburstNode parent, num radiusDiff) {
    if (parent.childCount == 0) {
      return;
    }
    final corner = series.corner.abs();
    final angleGap = series.angleGap.abs();
    final radiusGap = series.radiusGap.abs();
    final Arc parentArc = parent.attr.arc;
    if (parent.childCount == 1) {
      var ir = parentArc.outRadius + radiusGap;
      parent.firstChild.attr.arc = parentArc.copy(
        innerRadius: ir,
        outRadius: ir + radiusDiff,
        maxRadius: maxRadius,
      );
      parent.firstChild.updateTextPosition(series);
      return;
    }

    bool match = series.matchParent;
    if (!match) {
      num childAllValue = sumBy<SunburstNode>(parent.children, (p0) => p0.value);
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
      ele.attr.arc = Arc(
          innerRadius: ir,
          outRadius: or,
          startAngle: childStartAngle,
          sweepAngle: swa * dir,
          cornerRadius: corner,
          padAngle: angleGap,
          maxRadius: maxRadius,
          center: center);
      ele.updateTextPosition(series);
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
    var clickNode = findNode(offset);
    if (clickNode == null || clickNode == rootNode) {
      return;
    }
    if (clickNode is SunburstVirtualNode) {
      back();
      return;
    }
    _forward(clickNode);
  }

  void _forward(SunburstNode clickNode) {
    var oldBackNode = showRootNode;
    var hasBack = showRootNode is SunburstVirtualNode;
    var animation = getAnimation(LayoutType.update, -1);
    if (hasBack && oldBackNode != null) {
      oldBackNode.clear();
      clickNode.parent = null;
      oldBackNode.add(clickNode);
      oldBackNode.value = clickNode.value;

      var oldE = oldBackNode.attr.arc;
      var s = clickNode.attr.arc;
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
        clickNode.attr.arc = e;
        clickNode.updateTextPosition(series);
        _layoutNodeIterator(clickNode, clickNode.height + 1, false);
        notifyLayoutUpdate();
        return;
      }

      var tween = ChartDoubleTween(option: animation);
      tween.addListener(() {
        var t = tween.value;
        clickNode.attr.arc = Arc.lerp(s, e, t);
        clickNode.updateTextPosition(series);
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
    var bn = SunburstVirtualNode(clickNode, SunburstAttr(bs));

    var cs = clickNode.attr.arc;
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
      bn.attr.arc = be;
      bn.updateTextPosition(series);
      clickNode.attr.arc = ce;
      clickNode.updateTextPosition(series);
      _layoutNodeIterator(clickNode, clickNode.height + 1, false);
      showRootNode = bn;
      notifyLayoutUpdate();
      return;
    }

    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      var t = tween.value;
      bn.attr.arc = Arc.lerp(bs, be, t);
      bn.updateTextPosition(series);

      clickNode.attr.arc = Arc.lerp(cs, ce, t);
      clickNode.updateTextPosition(series);
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

    Map<SunburstNode, Arc> oldArcMap = {};
    first.each((node, index, startNode) {
      oldArcMap[node] = node.attr.arc;
      return false;
    });

    var parentData = first.data.parent?.parent;
    SunburstNode parentNode;
    if (parentData == null) {
      parentNode = rootNode!;
      bn = rootNode!;
      first.parent = bn;
    } else {
      parentData = first.data.parent!;
      parentNode = _nodeMap[parentData]!;
      parentNode.parent = null;
      bn = SunburstVirtualNode(parentNode, SunburstAttr(buildBackArc(center, parentNode.height + 1)));
    }
    bn.updateTextPosition(series);
    _layoutNodeIterator(bn, parentNode.height + 1, false);

    var animation = getAnimation(LayoutType.update, -1);
    if (animation == null) {
      showRootNode = bn;
      notifyLayoutUpdate();
      return;
    }

    Map<SunburstNode, Arc> arcMap = {};
    parentNode.each((node, index, startNode) {
      var arc = node.attr.arc;
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
        node.attr.arc = Arc.lerp(s, e, t);
        node.updateTextPosition(series);
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
    var hoverNode = findNode(offset);
    var oldNode = oldHoverNode;
    oldHoverNode = hoverNode;
    if (hoverNode == oldNode) {
      if (hoverNode != null && hoverNode is! SunburstVirtualNode) {
        //   sendHoverEvent(offset, hoverNode);
      }
      return;
    }
    List<NodeDiff<SunburstNode>> nl = [];
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
    var animation = series.animation;
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
  SunburstNode? findNode(Offset offset, [bool overlap = false]) {
    return showRootNode?.find((node, index, startNode) {
      Arc arc = node.attr.arc;
      return arc.contains(offset);
    });
  }
}
