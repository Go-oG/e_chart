import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import 'parallel_node.dart';

class ParallelHelper extends LayoutHelper<ParallelSeries> {
  List<ParallelNode> nodeList = [];

  ParallelHelper(super.context, super.view, super.series);

  double animationProcess = 1;

  @override
  void onLayout(LayoutType type) {
    List<ParallelNode> oldList = nodeList;
    List<ParallelNode> newList = convertData(series.data);
    layoutNode(newList);
    var animation = getAnimation(type, newList.length);
    if (animation == null || type == LayoutType.none || type == LayoutType.update) {
      nodeList = newList;
      animationProcess = 1;
      return;
    }

    var tween = ChartDoubleTween(option: animation);
    tween.addStartListener(() {
      nodeList = newList;
    });
    tween.addListener(() {
      animationProcess = tween.value;
      notifyLayoutUpdate();
    });
    context.addAnimationToQueue([AnimationNode(tween, animation, LayoutType.layout)]);
  }

  void layoutNode(List<ParallelNode> nodeList) {
    var coord = findParallelCoord();
    for (var node in nodeList) {
      eachNull(node.attr, (symbol, i) {
        var data = node.data.data[i];
        if (data == null) {
          node.attr[i].symbol = EmptySymbol.empty;
        } else {
          symbol?.center = coord.dataToPosition(i, data).center;
        }
      });
      node.updatePath(context, series);
    }
  }

  List<ParallelNode> convertData(List<ParallelGroup> list) {
    List<ParallelNode> nodeList = [];
    each(list, (p0, p1) {
      List<SymbolNode> snl = [];
      var bs = series.getBorderStyle(context, p0, p1, null);
      var ls = series.getLabelStyle(context, p0, p1, null);
      var node = ParallelNode(p0, p1, 0, snl, AreaStyle.empty, bs, ls);
      nodeList.add(node);
      each(p0.data, (data, i) {
        var node = SymbolNode(data, series.getSymbol(data, p0, i, p1), i, p1);
        node.data = data;
        snl.add(node);
      });
    });
    return nodeList;
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
      click ? sendClickEvent(offset, node) : sendHoverEvent(offset, node);
    }
    if (oldNode != null) {
      sendHoverEndEvent(oldNode);
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

  ParallelNode? findNode(Offset offset) {
    for (var node in nodeList) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }

  void onParallelAxisChange(List<int> dims) {
    if (dims.isEmpty) {
      return;
    }
    var coord = findParallelCoord();
    each(nodeList, (node, p1) {
      bool hasChange = false;
      for (var dim in dims) {
        if (node.attr.length <= dim) {
          continue;
        }
        var cn = node.attr[dim];
        if (cn.data == null) {
          continue;
        }
        var old = cn.center;
        cn.center = coord.dataToPosition(dim, cn.data!).center;

        if (old != cn.center) {
          hasChange = true;
        }
      }
      if (hasChange) {
        node.updatePath(context, series);
      }
    });
  }


}
