import 'dart:ui';

import '../../animation/index.dart';
import '../../option/style/index.dart';
import '../../series/series.dart';
import '../../utils/list_util.dart';
import '../index.dart';

abstract class LayoutHelper2<D extends RenderData, S extends ChartSeries> extends LayoutHelper<S> {
  List<D> dataSet = [];

  LayoutHelper2(super.context, super.view, super.series);

  LayoutHelper2.lazy() : super.lazy();

  ///初始化数据索引和样式
  ///包含样式索引和数据索引
  void initDataIndexAndStyle(List<D> dataList, [bool updateStyle = true]) {
    each(dataList, (data, p1) {
      data.dataIndex = p1;
      data.styleIndex = p1;
      if (updateStyle) {
        data.updateStyle(context, series);
      }
    });
  }

  @override
  void onClick(Offset localOffset) {
    onHandleHoverAndClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    onHandleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    onHandleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverEnd() {
    var old = oldHoverData;
    oldHoverData = null;
    if (old == null) {
      return;
    }
    sendHoverEndEvent(old);
    var oldAttr = old.toAttr();
    old.removeState(ViewState.hover);
    onUpdateNodeStyle(old);
    var animation = getAnimation(LayoutType.update, 2);

    if (animation == null) {
      notifyLayoutUpdate();
      return;
    }
    onRunUpdateAnimation([NodeDiff(old, oldAttr, old.toAttr(), true)], animation);
  }

  D? oldHoverData;

  void onHandleHoverAndClick(Offset offset, bool click) {
    var oldOffset = offset;
    offset = offset.translate(view.scrollX, view.scrollY);
    var clickData = findData(offset);
    if (oldHoverData == clickData) {
      if (clickData != null && !clickData.isDispose) {
        click ? sendClickEvent(oldOffset, clickData) : sendHoverEvent(oldOffset, clickData);
      }
      return;
    }
    var oldData = oldHoverData;
    oldHoverData = clickData;
    if (oldData != null) {
      sendHoverEndEvent(oldData);
    }
    if (clickData != null) {
      click ? sendClickEvent(oldOffset, clickData) : sendHoverEvent(oldOffset, clickData);
    }

    List<NodeDiff<D>> nl = [];

    if (oldData != null && !oldData.isDispose) {
      var oldAttr = oldData.toAttr();
      oldData.removeState(ViewState.hover);
      onUpdateNodeStyle(oldData);
      nl.add(NodeDiff(oldData, oldAttr, oldData.toAttr(), true));
    }

    if (clickData != null) {
      var newAttr = clickData.toAttr();
      clickData.addState(ViewState.hover);
      onUpdateNodeStyle(clickData);
      nl.add(NodeDiff(clickData, newAttr, clickData.toAttr(), false));
    }

    var animator = getAnimation(LayoutType.update, getAnimatorCountLimit());
    if (animator == null) {
      onHandleHoverAndClickEnd(oldData, clickData);
      notifyLayoutUpdate();
      return;
    }
    if (nl.isNotEmpty) {
      onRunUpdateAnimation(nl, animator);
    }
    onHandleHoverAndClickEnd(oldData, clickData);
  }

  int getAnimatorCountLimit() {
    return -1;
  }

  void onHandleHoverAndClickEnd(D? oldData, D? newData) {}

  void onUpdateNodeStyle(D data) {
    data.updateStyle(context, series);
  }

  void onRunUpdateAnimation(List<NodeDiff<D>> list, AnimatorOption animation) {
    List<ChartTween> tl = [];
    for (var diff in list) {
      var data = diff.data;
      var s = diff.startAttr;
      var e = diff.endAttr;
      var tween = ChartDoubleTween(option: animation);
      tween.addListener(() {
        var t = tween.value;
        data.itemStyle = AreaStyle.lerp(s.itemStyle, e.itemStyle, t);
        data.borderStyle = LineStyle.lerp(s.borderStyle, e.borderStyle, t);
        notifyLayoutUpdate();
      });
      tl.add(tween);
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  ///按照节点的绘制顺序排序
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

  ///查找节点数据
  ///如果overlap为 true，那么说明可能会存在重叠的View
  ///此时我们需要进行更加精确的判断
  ///父类默认没有实现该方法
  D? findData(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverData;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }

    ///这里倒序查找是因为当绘制顺序不一致时需要从最后查找
    var list = dataSet;
    for (int i = list.length - 1; i >= 0; i--) {
      var node = list[i];
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }
}
