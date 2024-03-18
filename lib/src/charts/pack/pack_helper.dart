import 'dart:math' as m;

import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'layout/siblings.dart';

class PackHelper extends LayoutHelper2<PackData, PackSeries> {
  Fun2<PackData, num>? _radiusFun;
  Fun2<PackData, num> _paddingFun = (a) {
    return 3;
  };
  PackData? rootNode;

  PackHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    var root = series.data;
    var c = initData2(root);
    var animation = getAnimation(type, c);
    if (animation == null) {
      layoutData(root);
      rootNode = root;
      return;
    }

    var oldList = rootNode?.iterator() ?? [];
    var newList = root.iterator();

    var an = DiffUtil.diff<PackData>(
      animation,
      oldList,
      newList,
      (dataList) => layoutData(root),
      (node, type) {
        return {'scale': type == DiffType.add ? 0 : node.scale};
      },
      (node, type) {
        return {'scale': type == DiffType.remove ? 0 : 1};
      },
      (node, s, e, t, type) {
        node.scale = lerpDouble(s['scale'] as num, e['scale'] as num, t)!;
      },
      (resultList, t) {
        dataSet = resultList;
        notifyLayoutUpdate();
      },
      onStart: () {
        rootNode = root;
      },
    );
    addAnimationToQueue(an);
  }

  int initData2(PackData root) {
    root.sum((p0) => p0.value);
    root.computeHeight();
    int c = 0;
    var h = root.height;
    root.each((node, index, startNode) {
      node.dataIndex = index;
      node.maxDeep = h;
      node.updateStyle(context, series);
      c++;
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
    return c;
  }

  void layoutData(PackData rootData) {
    var root = series.data;
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
    root.each((node, p1, p2) {
      double r = node.r;
      var align = series.getLabelAlign(node);
      if (align == Alignment.center) {
        node.label.updatePainter(
          text: node.label.text,
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
        node.label.updatePainter(text: node.label.text, maxWidth: r * 2 * 0.98, maxLines: 1);
      }
      return false;
    });
  }

  @override
  void onClick(Offset localOffset) {
    PackData? clickNode = findData(localOffset);
    if (clickNode != oldHoverData) {
      var oldHover = oldHoverData;
      oldHoverData = null;
      if (oldHover != null) {
        sendHoverEndEvent(oldHover);
      }
    }
    if (clickNode == null) {
      return;
    }

    sendClickEvent(localOffset, clickNode);
    var parent = clickNode.parent;
    PackData pn = parent ?? clickNode;

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
      view.scale = newScale;
      view.translationX = ntx;
      view.translationY = nty;
      updateDrawNodeList();
      notifyLayoutUpdate();
      return;
    }
    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      var t = tween.value;
      view.scale = lerpDouble(oldScale, newScale, t)!;
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
    List<PackData> nodeList = [];
    rootNode?.eachBefore((node, p1, p2) {
      if (needDraw(node)) {
        nodeList.add(node);
        return false;
      }
      return true;
    }, false);
    dataSet = nodeList;
  }

  @override
  PackData? findData(Offset offset, [bool overlap = false]) {
    if (rootNode == null) {
      return null;
    }
    PackData? parent;
    var scale = view.scaleX;
    List<PackData> rl = dataSet;
    List<PackData> next = [];
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

  PackHelper radius(Fun2<PackData, num> fun1) {
    _radiusFun = fun1;
    return this;
  }

  PackHelper padding(Fun2<PackData, num> fun1) {
    _paddingFun = fun1;
    return this;
  }

  bool needDraw(PackData node) {
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

double _defaultRadius(PackData d) {
  return m.sqrt(d.value);
}

bool Function(PackData, int, PackData) _radiusLeaf(Fun2<PackData, num> radiusFun) {
  return (PackData node, int b, PackData c) {
    if (node.notChild) {
      double r = m.max(0, radiusFun.call(node)).toDouble();
      node.r = r;
    }
    return false;
  };
}

bool Function(PackData, int, PackData) _packChildrenRandom(Fun2<PackData, num> paddingFun, num k, LCG random) {
  return (PackData node, int b, PackData c) {
    List<PackData> children = node.children;
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

bool Function(PackData, int, PackData) _translateChild(num k) {
  return (PackData node, int b, PackData c) {
    var parent = node.parent;
    node.r *= k;
    if (parent != null) {
      node.x = parent.x + k * node.x;
      node.y = parent.y + k * node.y;
    }
    return false;
  };
}
