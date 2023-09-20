import 'dart:math' as m;

import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'layout/siblings.dart';

class PackHelper extends LayoutHelper<PackSeries> {
  Fun2<PackNode, num>? _radiusFun;
  Rect _rect = const Rect.fromLTWH(0, 0, 1, 1);
  num _dx = 1;
  num _dy = 1;
  Fun2<PackNode, num> _paddingFun = (a) {
    return 3;
  };
  PackNode? rootNode;

  PackHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    var node = convertData(series.data);

    var h = node.height;
    node.each((node, index, startNode) {
      node.maxDeep = h;
      return false;
    });

    if (series.sortFun != null) {
      node.sort(series.sortFun!);
    } else {
      node.sort((p0, p1) => (p1.value - p0.value).toInt());
    }
    size(Rect.fromLTWH(0, 0, width, height));
    if (series.paddingFun != null) {
      padding(series.paddingFun!);
    }
    if (series.radiusFun != null) {
      radius(series.radiusFun!);
    }

    LCG random = DefaultLCG();
    node.x = _dx / 2;
    node.y = _dy / 2;
    if (_radiusFun != null) {
      node
          .eachBefore(_radiusLeaf(_radiusFun!))
          .eachAfter(_packChildrenRandom(_paddingFun, 0.5, random))
          .eachBefore(_translateChild(1));
    } else {
      node
          .eachBefore(_radiusLeaf(_defaultRadius))
          .eachAfter(_packChildrenRandom((e) {
            return 0;
          }, 1, random))
          .eachAfter(_packChildrenRandom(_paddingFun, node.r / m.min(_dx, _dy), random))
          .eachBefore(_translateChild(m.min(_dx, _dy) / (2 * node.r)));
    }

    ///修正位置
    if (_rect.left != 0 || _rect.top != 0) {
      node.each((p0, p1, p2) {
        p0.x += _rect.left;
        p0.y += _rect.top;
        return false;
      });
    }
    var oldRootNode = rootNode;
    var animation = series.animation;
    if (animation == null) {
      rootNode = node;
      return;
    }

    var an = DiffUtil.diffLayout<Rect, TreeData, PackNode>(
      animation,
      oldRootNode?.descendants() ?? [],
      node.descendants(),
      (data, node, add) {
        return Rect.fromCircle(center: node.center, radius: 0);
      },
      (s, e, t) {
        return Rect.lerp(s, e, t)!;
      },
      (resultList) {
        notifyLayoutUpdate();
      },
      () {
        rootNode = node;
      },
    );
    context.addAnimationToQueue(an);
  }

  PackNode convertData(TreeData data) {
    int i = 0;
    var rn = toTree<TreeData, Rect, PackNode>(data, (p0) => p0.children, (p0, p1) {
      var node = PackNode(
        p0,
        p1,
        i,
        Rect.zero,
        AreaStyle.empty,
        LineStyle.empty,
        LabelStyle.empty,
        value: p1.value,
      );
      i++;
      return node;
    });
    rn.sum((p0) => p0.value);
    rn.computeHeight();
    rn.each((node, index, startNode) {
      node.maxDeep = rn.height;
      node.itemStyle = series.getItemStyle(context, node) ?? AreaStyle.empty;
      node.borderStyle = series.getBorderStyle(context, node) ?? LineStyle.empty;
      node.labelStyle = series.getLabelStyle(context, node) ?? LabelStyle.empty;
      return false;
    });
    return rn;
  }

  double tx = 0;
  double ty = 0;
  double scale = 1;

  ///临时记录最大层级
  PackNode? showNode;

  @override
  void onClick(Offset localOffset) {
    PackNode? clickNode = findNode(localOffset);
    if (clickNode != _oldHoverNode) {
      var oldHover = _oldHoverNode;
      _oldHoverNode = null;
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
    showNode = pn;

    ///计算新的缩放系数
    double oldScale = scale;
    double newScale = m.min(width, height) * 0.5 / pn.r;

    ///计算偏移变化值
    double oldTx = tx;
    double oldTy = ty;
    double ntx = width / 2 - newScale * pn.x;
    double nty = height / 2 - newScale * pn.y;

    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      scale = newScale;
      tx = ntx;
      ty = nty;
      notifyLayoutUpdate();
      return;
    }
    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      var t = tween.value;
      scale = lerpDouble(oldScale, newScale, t)!;
      tx = lerpDouble(oldTx, ntx, t)!;
      ty = lerpDouble(oldTy, nty, t)!;
      notifyLayoutUpdate();
    });
    tween.start(context, true);
  }

  PackNode? _oldHoverNode;

  void _handleHover(Offset offset) {
    PackNode? hoverNode = findNode(offset);
    if (hoverNode == rootNode) {
      return;
    }
    if (hoverNode != null) {
      sendHoverEvent(offset, hoverNode);
    }
    if (hoverNode == _oldHoverNode) {
      return;
    }

    _oldHoverNode?.removeState(ViewState.hover);
    var oldNode = _oldHoverNode;
    if (oldNode != null) {
      sendHoverEndEvent(oldNode);
    }
    hoverNode?.addState(ViewState.hover);
    _oldHoverNode = hoverNode;
    notifyLayoutUpdate();
  }

  @override
  void onHoverStart(Offset localOffset) {
    _handleHover(localOffset);
  }

  @override
  void onHoverMove(Offset localOffset) {
    _handleHover(localOffset);
  }

  @override
  void onHoverEnd() {
    _oldHoverNode?.removeState(ViewState.hover);
    _oldHoverNode = null;
    notifyLayoutUpdate();
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    tx += diff.dx;
    ty += diff.dy;
    notifyLayoutUpdate();
  }

  PackNode? findNode(Offset offset) {
    if (rootNode == null) {
      return null;
    }
    List<PackNode> rl = [rootNode!];
    PackNode? parent;
    while (rl.isNotEmpty) {
      PackNode node = rl.removeAt(0);
      Offset center = node.center;
      center = center.scale(scale, scale);
      center = center.translate(tx, ty);
      if (offset.inCircle(node.r * scale, center: center)) {
        parent = node;
        if (node.hasChild) {
          rl = [...node.children];
        } else {
          return node;
        }
      }
    }
    if (parent != null) {
      return parent;
    }
    return null;
  }

  PackHelper radius(Fun2<PackNode, num> fun1) {
    _radiusFun = fun1;
    return this;
  }

  PackHelper size(Rect rect) {
    _rect = rect;
    _dx = rect.width;
    _dy = rect.height;
    return this;
  }

  PackHelper padding(Fun2<PackNode, num> fun1) {
    _paddingFun = fun1;
    return this;
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
