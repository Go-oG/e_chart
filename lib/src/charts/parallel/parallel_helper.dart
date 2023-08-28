import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class ParallelHelper extends LayoutHelper<ParallelSeries> {
  List<ParallelNode> nodeList = [];

  ParallelHelper(super.context, super.series);

  double animationProcess = 1;

  @override
  void onLayout(LayoutType type) {
    List<ParallelNode> oldList = nodeList;
    List<ParallelNode> newList = convertData(series.data);
    layoutNode(newList);

    var animation = series.animation;
    if (animation == null || type == LayoutType.none) {
      nodeList = newList;
      animationProcess = 1;
      return;
    }
    var coord = findParallelCoord();
    int axisCount = coord.getAxisCount();
    var direction = coord.direction;
    var an = DiffUtil.diffLayout<ParallelAttr, ParallelGroup, ParallelNode>(
      animation,
      oldList,
      newList,
      (data, node, add) {
        if (type == LayoutType.update) {
          List<Offset?> ol = [];
          eachNull(node.attr.offsetList, (offset, p1) {
            if (offset == null) {
              ol.add(null);
            } else {
              double dx = direction == Direction.vertical ? 0 : offset.dx;
              double dy = direction == Direction.vertical ? offset.dy : height;
              ol.add(Offset(dx, dy));
            }
          });
          return ParallelAttr(ol, axisCount, direction, width, height);
        }
        return node.attr;
      },
      (s, e, t) {
        if (type == LayoutType.layout) {
          animationProcess = t;
          return e;
        }

        animationProcess = 1;
        List<Offset?> pl = [];
        for (int i = 0; i < s.offsetList.length; i++) {
          var so = s.offsetList[i];
          var eo = e.offsetList[i];
          pl.add(Offset.lerp(so, eo, t));
        }
        return ParallelAttr(pl, axisCount, direction, width, height);
      },
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
    );
    context.addAnimationToQueue(an);
  }

  void layoutNode(List<ParallelNode> nodeList) {
    var coord = findParallelCoord();
    int axisCount = coord.getAxisCount();
    var direction = coord.direction;
    for (var node in nodeList) {
      List<Offset?> ol = [];
      for (int i = 0; i < node.data.data.length; i++) {
        var data = node.data.data[i];
        if (data == null) {
          ol.add(null);
        } else {
          ol.add(coord.dataToPosition(i, data).center);
        }
      }
      node.attr = ParallelAttr(ol, axisCount, direction, width, height);
    }
  }

  @override
  void onClick(Offset localOffset) {
    handleHoverAndClick(localOffset, true);
  }

  ParallelNode? _oldHoverNode;

  void handleHoverAndClick(Offset offset, bool click) {
    var node = findNode(offset);
    if (node == _oldHoverNode) {
      return;
    }
    var oldNode = _oldHoverNode;
    _oldHoverNode = node;
    node?.addState(ViewState.hover);
    node?.addState(ViewState.selected);
    oldNode?.removeState(ViewState.hover);
    oldNode?.removeState(ViewState.selected);
    if (node != null) {
      click ? sendClickEvent2(offset, node) : sendHoverInEvent2(offset, node);
    }
    if (oldNode != null) {
      sendHoverOutEvent2(oldNode);
    }
    notifyLayoutUpdate();
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
    var oldNode = _oldHoverNode;
    _oldHoverNode = null;
    oldNode?.removeState(ViewState.selected);
    oldNode?.removeState(ViewState.hover);
    if (oldNode != null) {
      notifyLayoutUpdate();
    }
  }

  @override
  SeriesType get seriesType => SeriesType.parallel;

  ParallelNode? findNode(Offset offset) {
    for (var node in nodeList) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }

  List<ParallelNode> convertData(List<ParallelGroup> list) {
    List<ParallelNode> nodeList = [];
    var coord = findParallelCoord();
    int axisCount = coord.getAxisCount();
    var direction = coord.direction;
    each(list, (p0, p1) {
      List<SymbolNode> snl = [];
      each(p0.data, (symbol, i) {
        snl.add(SymbolNode(symbol, i, p1, Offset.zero));
      });
      nodeList.add(ParallelNode(snl, p0, p1, 0, ParallelAttr([], axisCount, direction, width, height)));
    });
    return nodeList;
  }
}

class ParallelNode extends DataNode<ParallelAttr, ParallelGroup> {
  List<SymbolNode> symbolList;

  ParallelNode(this.symbolList, super.data, super.dataIndex, super.groupIndex, super.attr);

  bool contains(Offset offset) {
    return attr.contains(offset);
  }
}

class ParallelAttr {
  final List<Offset?> offsetList;
  final int axisCount;
  final num w;
  final num h;
  final Direction direction;
  final Size? symbolSize;

  bool _smooth = false;
  bool _connectNull = false;
  List<num> _dash = [];

  ParallelAttr(this.offsetList, this.axisCount, this.direction, this.w, this.h, [this.symbolSize]);

  OptPath? _optPath;
  OptPath? _dashPath;

  OptPath getPath(bool smooth, bool connectNull, List<num> dash) {
    if (_optPath != null && smooth == _smooth && connectNull == _connectNull && equalList(_dash, dash)) {
      if (dash.isNotEmpty) {
        return _dashPath!;
      }
      return _optPath!;
    }

    if (_smooth == smooth && connectNull == _connectNull && _optPath != null) {
      _dash = dash;
      if (dash.isEmpty) {
        _dashPath = null;
        return _optPath!;
      }
      return _dashPath = OptPath.not(_optPath!.path.dashPath(dash));
    }

    _smooth = smooth;
    _connectNull = connectNull;
    _dash = dash;

    num dis = 0;
    each(offsetList, (p0, i) {
      if (i < 1) {
        return;
      }
      var pre = offsetList[i - 1];
      var cur = offsetList[i];
      if (pre != null && cur != null) {
        dis = max([dis, cur.distance2(pre)]);
      }
    });

    var path = _buildPath(smooth, connectNull);

    num len;
    if (dis > 0) {
      len = dis;
    } else {
      len = 2 * (direction == Direction.horizontal ? w : h) / axisCount;
    }
    _optPath = OptPath(path, len);
    if (dash.isNotEmpty) {
      return OptPath.not(path.dashPath(dash));
    }
    return _optPath!;
  }

  Path _buildPath(bool smooth, bool connectNull) {
    List<List<Offset>> ol = [];
    if (connectNull) {
      List<Offset> tmp = [];
      for (var off in offsetList) {
        if (off != null) {
          tmp.add(off);
        }
      }
      if (tmp.length >= 2) {
        ol.add(tmp);
      }
    } else {
      ol = splitListForNull(offsetList);
    }

    var path = Path();
    for (var list in ol) {
      if (list.length < 2) {
        continue;
      }
      var first = list.first;
      path.moveTo(first.dx, first.dy);
      if (smooth) {
        Line(list, smooth: true).appendToPathEnd(path);
      } else {
        for (int i = 1; i < list.length; i++) {
          path.lineTo(list[i].dx, list[i].dy);
        }
      }
    }
    return path;
  }

  bool contains(Offset offset) {
    if (_optPath == null) {
      return false;
    }
    return _optPath!.path.contains(offset);
  }
}
