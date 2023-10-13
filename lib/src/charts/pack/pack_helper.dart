import 'dart:math' as m;

import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';
import 'layout/siblings.dart';

class PackHelper extends LayoutHelper2<PackNode, PackSeries> {
  Fun2<PackNode, num>? _radiusFun;
  Fun2<PackNode, num> _paddingFun = (a) {
    return 3;
  };
  PackNode? rootNode;

  List<PackNode> showNodeList = [];

  PackHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    var root = convertData(series.data);
    var h = root.height;
    root.each((node, index, startNode) {
      node.maxDeep = h;
      return false;
    });

    if (series.sortFun != null) {
      root.sort(series.sortFun!);
    } else {
      root.sort((p0, p1) => (p1.value - p0.value).toInt());
    }
    if (series.paddingFun != null) {
      padding(series.paddingFun!);
    }
    if (series.radiusFun != null) {
      radius(series.radiusFun!);
    }

    LCG random = DefaultLCG();
    root.x = width / 2;
    root.y = height / 2;
    if (_radiusFun != null) {
      root
          .eachBefore(_radiusLeaf(_radiusFun!))
          .eachAfter(_packChildrenRandom(_paddingFun, 0.5, random))
          .eachBefore(_translateChild(1));
    } else {
      root
          .eachBefore(_radiusLeaf(_defaultRadius))
          .eachAfter(_packChildrenRandom((e) {
            return 0;
          }, 1, random))
          .eachAfter(_packChildrenRandom(_paddingFun, root.r / m.min(width, height), random))
          .eachBefore(_translateChild(m.min(width, height) / (2 * root.r)));
    }

    ///计算文字位置
    int c = 0;
    root.each((node, p1, p2) {
      double r = node.r;
      var align = series.getLabelAlign(node);
      if (align == Alignment.center) {
        node.label.updatePainter(
          text: node.data.name ?? DynamicText.empty,
          offset: node.center,
          align: Alignment.center,
          maxWidth: r * 2 * 0.98,
          maxLines: 1,
        );
      } else {
        ChartAlign(align: align, inside: true).fill(
          node.label,
          Rect.fromCircle(center: node.center, radius: r),
          node.label.style,
          Direction.vertical,
        );
        node.label.updatePainter(text: node.data.name ?? DynamicText.empty, maxWidth: r * 2 * 0.98, maxLines: 1);
      }
      c++;
      return false;
    });

    var animation = getAnimation(type, c);
    if (animation == null) {
      rootNode = root;
      return;
    }
    var an = DiffUtil.diffLayout3<PackNode>(animation, [], root.iterator(), (node, type) {
      return {'scale': type == DiffType.add ? 0 : node.scale};
    }, (node, type) {
      return {'scale': type == DiffType.remove ? 0 : 1};
    }, (node, s, e, t, type) {
      node.scale = lerpDouble(s['scale'] as num, e['scale'] as num, t)!;
    }, (resultList) {
      showNodeList = resultList;
      notifyLayoutUpdate();
    }, () {
      rootNode = root;
    });
    context.addAnimationToQueue(an);
  }

  PackNode convertData(TreeData data) {
    int i = 0;
    var rn = toTree<TreeData, Rect, PackNode>(data, (p0) => p0.children, (p0, p1) {
      var node = PackNode(p0, p1, i, Rect.zero, AreaStyle.empty, LineStyle.empty, LabelStyle.empty, value: p1.value);
      i++;
      return node;
    });
    rn.sum((p0) => p0.value);
    rn.computeHeight();
    rn.each((node, index, startNode) {
      node.maxDeep = rn.height;
      node.updateStyle(context, series);
      return false;
    });
    return rn;
  }

  @override
  void onClick(Offset localOffset) {
    PackNode? clickNode = findNode(localOffset);
    if (clickNode != oldHoverNode) {
      var oldHover = oldHoverNode;
      oldHoverNode = null;
      if (oldHover != null) {
        sendHoverEndEvent(oldHover);
      }
    }
    if (clickNode == null) {
      return;
    }

    sendClickEvent(localOffset, clickNode);
    var parent = clickNode.parent;
    PackNode pn = parent ?? clickNode;

    ///计算新的缩放系数
    double oldScale = view.scaleX;
    double newScale = m.min(width, height) * 0.5 / pn.r;

    ///计算偏移变化值
    double oldTx = view.translationX;
    double oldTy = view.translationY;
    double ntx = width / 2 - newScale * pn.x;
    double nty = height / 2 - newScale * pn.y;

    if (newScale == oldScale && ntx == oldTx && nty == oldTy) {
      return;
    }

    var animation = getAnimation(LayoutType.update, -1);
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      view.scaleX = view.scaleY = newScale;
      view.translationX = ntx;
      view.translationY = nty;
      updateDrawNodeList();
      notifyLayoutUpdate();
      return;
    }
    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      var t = tween.value;
      view.scaleX = view.scaleY = lerpDouble(oldScale, newScale, t)!;
      view.translationX = lerpDouble(oldTx, ntx, t)!;
      view.translationY = lerpDouble(oldTy, nty, t)!;
      updateDrawNodeList();
      notifyLayoutUpdate();
    });
    tween.start(context, true);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    updateDrawNodeList();
    notifyLayoutUpdate();
  }

  void updateDrawNodeList() {
    List<PackNode> nodeList = [];
    rootNode?.eachBefore((node, p1, p2) {
      if (needDraw(node)) {
        nodeList.add(node);
        return false;
      }
      return true;
    }, false);
    showNodeList = nodeList;
  }

  @override
  PackNode? findNode(Offset offset, [bool overlap = false]) {
    if (rootNode == null) {
      return null;
    }
    PackNode? parent;
    var scale = view.scaleX;
    List<PackNode> rl = showNodeList;
    List<PackNode> next = [];
    while (rl.isNotEmpty) {
      for (var node in rl) {
        var dx = node.x * scale + view.translationX;
        var dy = node.y * scale + view.translationY;
        if (!offset.inCircle2(node.r * scale, dx, dy)) {
          continue;
        }
        if (node.notChild) {
          return node;
        }
        parent = node;
        next.addAll(node.children);
      }
      rl = next;
      next = [];
    }
    return parent;
  }

  PackHelper radius(Fun2<PackNode, num> fun1) {
    _radiusFun = fun1;
    return this;
  }

  PackHelper padding(Fun2<PackNode, num> fun1) {
    _paddingFun = fun1;
    return this;
  }

  bool needDraw(PackNode node) {
    Rect rect = boxBound;
    var scale = view.scaleX;
    var cx = node.x * scale;
    cx += view.translationX;
    var cy = node.y * scale;
    cy += view.translationY;
    if (rect.overlapCircle2(cx, cy, node.r * scale)) {
      return true;
    }
    return false;
  }
}

double _defaultRadius(PackNode d) {
  return m.sqrt(d.value);
}

bool Function(PackNode, int, PackNode) _radiusLeaf(Fun2<PackNode, num> radiusFun) {
  return (PackNode node, int b, PackNode c) {
    if (node.notChild) {
      double r = m.max(0, radiusFun.call(node)).toDouble();
      node.r = r;
    }
    return false;
  };
}

bool Function(PackNode, int, PackNode) _packChildrenRandom(Fun2<PackNode, num> paddingFun, num k, LCG random) {
  return (PackNode node, int b, PackNode c) {
    List<PackNode> children = node.children;
    if (children.isNotEmpty) {
      int i, n = children.length;
      num r = paddingFun(node) * k, e;
      if (r != 0) {
        for (i = 0; i < n; ++i) {
          children[i].r += r;
        }
      }
      e = Siblings.packSiblingsRandom(children, random);
      if (r != 0) {
        for (i = 0; i < n; ++i) {
          children[i].r -= r;
        }
      }
      node.r = e + r.toDouble();
    }
    return false;
  };
}

bool Function(PackNode, int, PackNode) _translateChild(num k) {
  return (PackNode node, int b, PackNode c) {
    var parent = node.parent;
    node.r *= k;
    if (parent != null) {
      node.x = parent.x + k * node.x;
      node.y = parent.y + k * node.y;
    }
    return false;
  };
}
