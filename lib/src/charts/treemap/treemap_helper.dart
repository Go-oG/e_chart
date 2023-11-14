import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TreeMapHelper extends LayoutHelper2<TreeMapData, TreeMapSeries> {
  static final TreeMapData _empty = TreeMapData(null, List.empty(), 0);
  TreeMapData _rootData = _empty;

  TreeMapData get root => _rootData;

  TreeMapHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    var sort = series.sortFun;
    var root = series.data;
    if (sort != null) {
      root.sort(sort, true);
    }
    root.sum((p0) => p0.value);
    root.setDeep(0);
    root.computeHeight();
    root.setMaxDeep(root.height);
    root.each((node, index, startNode) {
      node.updateStyle(context, series);
      return false;
    });

    root.attr = boxBound;
    int c = series.initShowDepth;
    if (c <= 0) {
      c = root.maxDeep;
    }
    List<List<TreeMapData>> levelList = root.levelEach(c);
    Set<TreeMapData> drawSet = {};
    each(levelList, (levels, p1) {
      for (var c in levels) {
        _layoutChildren(c, c.attr);
        if (c.notChild) {
          drawSet.add(c);
        }
      }
      if (p1 == levelList.length - 1) {
        drawSet.addAll(levels);
      }
    });
    List<TreeMapData> drawList = List.from(drawSet);

    _rootData = root;
    nodeList = drawList;
    nodeList.sort((a, b) {
      return a.height.compareTo(b.height);
    });
  }

  void _layoutChildren(TreeMapData parent, Rect rect) {
    parent.attr = rect;
    if (parent.notChild) {
      return;
    }

    ///处理自身的padding
    var x0 = rect.left - getPaddingLeft(parent);
    var y0 = rect.top - getPaddingTop(parent);
    var x1 = rect.right - getPaddingRight(parent);
    var y1 = rect.bottom - getPaddingBottom(parent);
    if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
    if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
    var cRect = Rect.fromLTRB(x0, y0, x1, y1);
    series.layout.onLayout(parent, HierarchyOption(series, cRect.width, cRect.height, cRect, cRect));
    var paddingInner = getPaddingInner(parent);
    if (paddingInner > 0) {
      double v = paddingInner / 2;
      each(parent.children, (child, p1) {
        child.attr = child.attr.deflate(v);
      });
    }
    bool round = series.round;
    each(parent.children, (p0, p1) {
      if (round) {
        var rect = p0.attr;
        var r2 = Rect.fromLTRB(
          rect.left.roundToDouble(),
          rect.top.roundToDouble(),
          rect.right.roundToDouble(),
          rect.bottom.roundToDouble(),
        );
        p0.attr = r2;
      }

      p0.updateLabelPosition(context, series);
    });
  }

  num getPaddingInner(TreeMapData data) {
    num v = series.paddingInner?.call(data) ?? 0;
    return max([v, 0]);
  }

  num getPaddingTop(TreeMapData data) {
    num v = series.paddingTop?.call(data) ?? 0;
    return max([v, 0]);
  }

  num getPaddingLeft(TreeMapData data) {
    num v = series.paddingLeft?.call(data) ?? 0;
    return max([v, 0]);
  }

  num getPaddingRight(TreeMapData data) {
    num v = series.paddingRight?.call(data) ?? 0;
    return max([v, 0]);
  }

  num getPaddingBottom(TreeMapData data) {
    num v = series.paddingBottom?.call(data) ?? 0;
    return max([v, 0]);
  }

  bool roundNode(TreeMapData node, int index, TreeMapData other) {
    var rect = node.attr;
    var r2 = Rect.fromLTRB(
      rect.left.roundToDouble(),
      rect.top.roundToDouble(),
      rect.right.roundToDouble(),
      rect.bottom.roundToDouble(),
    );
    node.attr = r2;
    return false;
  }

  @override
  void onClick(Offset localOffset) {
    handleClick(localOffset.translate(-translationX, -translationY));
  }

  ///处理点击事件
  void handleClick(Offset offset) {
    var clickNode = findNode(offset);
    if (clickNode == null) {
      Logger.i('无法找到点击节点');
      return;
    }
    if (clickNode == _rootData && clickNode.children.isEmpty) {
      back();
      return;
    }
    zoomOut(clickNode);
  }

  ///回退
  void back() {
    //TODO 待实现
  }

  @override
  TreeMapData? findNode(Offset offset, [bool overlap = false]) {
    for (var c in nodeList) {
      if (c.contains(offset)) {
        return c;
      }
    }
    return null;
  }

  /// 缩小
  void zoomIn(TreeMapData node, double ratio) {}

  ///放大
  void zoomOut(TreeMapData clickNode) {
    // if (clickNode == rootNode) {
    //   return;
    // }
    // series.onClick?.call(clickNode.data);
    // showStack.clear();
    // showStack.addAll(clickNode.ancestors().reversed);
    // adjustDrawList();
    //
    // ///保持当前比例不变
    // Size rootSize = rootNode.getPosition().size;
    // double rootArea = rootSize.width * rootSize.height;
    // double areaRadio = clickNode.value / rootNode.value;
    //
    // ///计算新的画布大小
    // double cw = 0;
    // double ch = 0;
    //
    // double factory = clickNode.childCount > 1 ? 0.45 : 0.25;
    //
    // double w = min([width, height]) * factory;
    // double h = w * 0.75;
    //
    // double rootArea2 = w * h / areaRadio;
    // double scale = rootArea2 / rootArea;
    // cw = rootSize.width * scale;
    // ch = cw / (rootSize.width / rootSize.height);
    //
    // if (cw < width || ch < height) {
    //   cw = width;
    //   ch = height;
    // }
    //
    // rootNode.each((node, index, startNode) {
    //   node.start = node.cur.copy();
    //   return false;
    // });
    //
    // ///重新测量位置
    // rootNode.setPosition(Rect.fromLTWH(0, 0, cw, ch));
    // helper.layout(rootNode, rootNode.getPosition());
    // rootNode.each((node, index, startNode) {
    //   node.end = node.cur.copy();
    //   return false;
    // });
    //
    // ///计算平移量
    // Offset center = clickNode.getPosition().center;
    // double tw = width / 2 - center.dx;
    // double th = height / 2 - center.dy;
    //
    // double diffTx = (tw - tx);
    // double diffTy = (th - ty);
    // double oldTx = tx;
    // double oldTy = ty;
    //
    // /// 执行动画
    // ChartRectTween rectTween = ChartRectTween(Rect.zero, Rect.zero, props: series.animatorProps);
    // ChartDoubleTween tween = ChartDoubleTween(props: series.animatorProps);
    // tween.addListener(() {
    //   double v = tween.value;
    //   tx = oldTx + diffTx * v;
    //   ty = oldTy + diffTy * v;
    //   rootNode.each((tmp, index, startNode) {
    //     rectTween.changeValue(tmp.start.position, tmp.end.position);
    //     tmp.setPosition(rectTween.safeGetValue(v));
    //     return false;
    //   });
    //   invalidate();
    // });
    // tween.start(context, true);
  }

  @override
  void dispose() {
    super.dispose();
    _rootData = _empty;
  }
}
