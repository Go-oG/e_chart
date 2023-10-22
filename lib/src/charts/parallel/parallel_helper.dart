import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class ParallelHelper extends LayoutHelper<ParallelSeries> {
  List<ParallelData> nodeList = [];

  ParallelHelper(super.context, super.view, super.series);

  double animationProcess = 1;

  @override
  void onLayout(LayoutType type) {
    List<ParallelData> oldList = nodeList;
    List<ParallelData> newList = [...series.data];
    initData(newList);

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

  void layoutNode(List<ParallelData> nodeList) {
    var coord = findParallelCoord();
    for (var node in nodeList) {
      eachNull(node.attr, (symbol, i) {
        var data = node.data[i];
        if (data == null) {
          node.attr[i].symbol = EmptySymbol.empty;
        } else {
          symbol?.center = coord.dataToPosition(i, data).center;
        }
      });
      node.updatePath(context, series);
    }
  }

  void initData(List<ParallelData> list) {
    each(list, (data, p1) {
      List<SymbolNode> snl = [];
      data.attr = snl;
      data.updateStyle(context, series);
      each(data.data, (cd, i) {
        var node = SymbolNode(cd, series.getSymbol(cd, data), i, p1);
        node.data = data;
        snl.add(node);
      });
    });
  }

  @override
  void onClick(Offset localOffset) {
    handleHoverAndClick(localOffset, true);
  }

  ParallelData? _oldHoverNode;

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

  ParallelData? findNode(Offset offset) {
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
