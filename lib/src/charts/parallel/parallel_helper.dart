import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import 'parallel_node.dart';

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
          List<SymbolNode> ol = [];
          eachNull(node.attr.symbolList, (symbol, p1) {
            var offset = symbol?.attr;
            if (offset == null) {
              ol.add(SymbolNode(null, p1, node.groupIndex));
            } else {
              double dx = direction == Direction.vertical ? 0 : offset.dx;
              double dy = direction == Direction.vertical ? offset.dy : height;
              var node = SymbolNode(symbol!.data, symbol.dataIndex, symbol.groupIndex);
              node.attr = Offset(dx, dy);
              ol.add(node);
            }
          });
          return ParallelAttr(
            ol,
            axisCount,
            direction,
            width,
            height,
          );
        }
        return node.attr;
      },
      (s, e, t) {
        if (type == LayoutType.layout) {
          animationProcess = t;
          return e;
        }

        animationProcess = 1;
        List<SymbolNode> pl = [];
        for (int i = 0; i < s.symbolList.length; i++) {
          var so = s.symbolList[i].attr;
          var eo = e.symbolList[i].attr;
          var ed = e.symbolList[i];
          var ro = Offset.lerp(so, eo, t)!;
          pl.add(SymbolNode(ed.data, ed.dataIndex, ed.groupIndex)..attr = ro);
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
    for (var node in nodeList) {
      eachNull(node.attr.symbolList, (symbol, i) {
        var data = node.data.data[i];
        if (data == null) {
          node.attr.symbolList[i].symbol = null;
        } else {
          Offset c = coord.dataToPosition(i, data).center;
          symbol?.attr = c;
        }
      });
    }
  }

  ChartSymbol? getSymbol(dynamic data, ParallelGroup group, int dataIndex, int groupIndex) {
    var fun = series.symbolFun;
    if (fun != null) {
      return fun.call(data, group, dataIndex, groupIndex, null);
    }
    return null;
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
      var node = ParallelNode(
        p0,
        p1,
        0,
        ParallelAttr(snl, axisCount, direction, width, height),
        AreaStyle.empty,
        series.getBorderStyle(context, p0, p1, null) ?? LineStyle.empty,
        series.getLabelStyle(context, p0, p1, null) ?? LabelStyle.empty,
      );
      nodeList.add(node);
      each(p0.data, (data, i) {
        var node = SymbolNode(getSymbol(data, p0, i, p1), i, p1);
        node.originData = data;
        snl.add(node);
      });
    });
    return nodeList;
  }
}
