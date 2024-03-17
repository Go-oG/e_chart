import 'dart:ui';

import 'package:e_chart/e_chart.dart';

/// 适用于 节点-边的布局帮助者
abstract class LayoutHelper3<D extends RenderData, L extends RenderData, S extends ChartSeries> extends LayoutHelper<S> {
  List<D> dataSet = [];
  List<L> linkSet = [];

  LayoutHelper3(super.context, super.view, super.series);

  @override
  void onClick(Offset localOffset) {
    handleHoverAndClick(localOffset, true);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
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
    handleCancel();
  }

  D? oldHoverData;

  L? oldHoverLink;

  void handleHoverAndClick(Offset local, bool click) {
    var offset = local.translate(-translationX, -translationY);
    dynamic clickData = findDataOrLink(offset);
    if (clickData == null) {
      handleCancel();
      return;
    }

    oldHoverLink = null;
    oldHoverData = null;

    if (clickData is L) {
      L link = clickData;
      oldHoverLink = link;
      changeDataStatus(null, link);
      notifyLayoutUpdate();
      return;
    }
    if (clickData is D) {
      D data = clickData;
      oldHoverData = data;
      changeDataStatus(data, null);
      notifyLayoutUpdate();
      return;
    }
  }

  void handleCancel() {
    bool hasChange = false;
    if (oldHoverLink != null) {
      oldHoverLink?.removeStates([ViewState.selected, ViewState.hover]);
      oldHoverLink = null;
      hasChange = true;
    }
    if (oldHoverData != null) {
      oldHoverData?.removeStates([ViewState.selected, ViewState.hover]);
      oldHoverData = null;
      hasChange = true;
    }
    if (hasChange) {
      resetDataStatus();
      notifyLayoutUpdate();
    }
  }

  D? findData(Offset offset) {
    for (var d in dataSet) {
      if (d.contains(offset)) {
        return d;
      }
    }
    return null;
  }

  L? findLink(Offset offset) {
    for (var link in linkSet) {
      if (link.contains(offset)) {
        return link;
      }
    }
    return null;
  }

  ///找到点击节点(优先节点而不是边)
  dynamic findDataOrLink(Offset offset, [bool linkFirst = false]) {
    if (linkFirst) {
      var l = findLink(offset);
      if (l != null) {
        return l;
      }
      return findData(offset);
    } else {
      var d = findData(offset);
      if (d != null) {
        return d;
      }
      return findLink(offset);
    }
  }

  //处理数据状态
  void changeDataStatus(D? data, L? link) {
    Set<L> linkSet = {};
    Set<D> dataSet = {};
    if (link != null) {
      linkSet.add(link);
      dataSet.add(getLinkTarget(link));
      dataSet.add(getLinkSource(link));
    }

    if (data != null) {
      dataSet.add(data);
      linkSet.addAll(getDataLink(data));
      for (var element in getDataInLink(data)) {
        dataSet.add(getLinkSource(element));
      }
      dataSet.addAll(getDataOutLink(data).map((e) => getLinkTarget(e)));
    }

    bool hasSelect = linkSet.isNotEmpty || dataSet.isNotEmpty;
    var status = [ViewState.hover, ViewState.selected];

    for (var ele in linkSet) {
      ele.cleanState();
      if (hasSelect) {
        if (dataSet.contains(getLinkTarget(ele)) && dataSet.contains(getLinkSource(ele))) {
          ele.addStates(status);
        } else {
          ele.addState(ViewState.disabled);
        }
      }
      ele.updateStyle(context, series);
    }

    for (var ele in dataSet) {
      ele.cleanState();
      if (hasSelect) {
        if (dataSet.contains(ele)) {
          ele.addStates(status);
        } else {
          ele.addState(ViewState.disabled);
        }
      }
      ele.updateStyle(context, series);
    }
  }

  /// 重置数据状态
  void resetDataStatus() {
    for (var ele in linkSet) {
      ele.cleanState();
      ele.updateStyle(context, series);
    }
    for (var ele in dataSet) {
      ele.cleanState();
      ele.updateStyle(context, series);
    }
  }

  // @override
  // Offset getTranslation() {
  //   return view.translation;
  // }

  D getLinkSource(L link);

  D getLinkTarget(L link);

  List<L> getDataLink(D data) {
    return [...getDataInLink(data), ...getDataOutLink(data)];
  }

  List<L> getDataInLink(D data);

  List<L> getDataOutLink(D data);

  void sortList(List<D> nodeList) {
    nodeList.sort((a, b) {
      if (a.drawIndex == 0 && b.drawIndex == 0) {
        return a.dataIndex.compareTo(b.dataIndex);
      }
      if (a.drawIndex != 0) {
        return 1;
      }
      return 0;
    });
  }
}
