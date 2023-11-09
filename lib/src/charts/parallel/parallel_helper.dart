import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class ParallelHelper extends LayoutHelper<ParallelSeries> {
  List<ParallelData> dataList = [];

  ParallelHelper(super.context, super.view, super.series);

  double animationProcess = 1;

  @override
  void onLayout(LayoutType type) {
    List<ParallelData> oldList = dataList;
    List<ParallelData> newList = [...series.data];
    initData(newList);
    layoutData(newList);
    var animation = getAnimation(type, newList.length);
    if (animation == null || type == LayoutType.none || type == LayoutType.update) {
      dataList = newList;
      animationProcess = 1;
      return;
    }

    var tween = ChartDoubleTween(option: animation);
    tween.addStartListener(() {
      dataList = newList;
    });
    tween.addListener(() {
      animationProcess = tween.value;
      notifyLayoutUpdate();
    });
    context.addAnimationToQueue([AnimationNode(tween, animation, LayoutType.layout)]);
  }

  void layoutData(List<ParallelData> dataList) {
    var parallelCoord = findParallelCoord();
    for (var parent in dataList) {
      ParallelChildData? preData;
      each(parent.data, (data, i) {
        if (data.dataIsNull) {
          if (!parent.connectNull) {
            preData = null;
          }
        } else {
          data.point = parallelCoord.dataToPosition(i, data.data).center;
          if (preData != null) {
            preData!.lines = [preData!.point, data.point];
          }
          preData = data;
        }
      });
      each(parent.data, (p0, p1) {
        p0.updatePath();
      });
    }
  }

  void initData(List<ParallelData> list) {
    each(list, (parent, p1) {
      parent.dataIndex=p1;
      parent.groupIndex=p1;
      each(parent.data, (cd, i) {
        cd.parent = parent;
        cd.groupIndex = p1;
        cd.dataIndex = i;
      });
      parent.updateStyle(context, series);
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
    if(node!=null){
      each(node.data, (p0, p1) {
        p0.addState(ViewState.hover);
        p0.addState(ViewState.selected);
      });
    }
    if(oldNode!=null){
      each(oldNode.data, (p0, p1) {
        p0.removeState(ViewState.hover);
        p0.removeState(ViewState.selected);
      });
    }

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
    for (var node in dataList) {
      if(node.contains(offset)){return node;}
    }
    return null;
  }

  void onParallelAxisChange(List<int> dims) {
    if (dims.isEmpty) {
      return;
    }
    var coord = findParallelCoord();
    each(dataList, (parent, p1) {
      bool hasChange = false;
      for (var dim in dims) {
        if (parent.data.length <= dim) {
          continue;
        }
        var cn = parent.data[dim];
        if (cn.data == null) {
          continue;
        }
        var old = cn.point;
        cn.point = coord.dataToPosition(dim, cn.data!).center;
        if (old != cn.point) {
          hasChange = true;
        }
      }
      if (hasChange) {
        each(parent.data, (p0, p1) {
          p0.updatePath();
        });
      }
    });
  }
}
