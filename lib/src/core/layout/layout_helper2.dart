import 'dart:ui';

import 'package:e_chart/src/ext/offset_ext.dart';

import '../../animation/index.dart';
import '../../component/style/index.dart';
import '../index.dart';

abstract class LayoutHelper2<N extends DataNode, S extends ChartSeries> extends LayoutHelper<S> {
  List<N> nodeList = [];

  LayoutHelper2(super.context, super.view, super.series);

  LayoutHelper2.lazy() : super.lazy();

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    notifyLayoutUpdate();
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
    var old = oldHoverNode;
    oldHoverNode = null;
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

  N? oldHoverNode;

  void onHandleHoverAndClick(Offset offset, bool click) {
    var oldOffset = offset;
    Offset scroll = getTranslation();
    offset = offset.translate2(scroll.invert);
    var clickNode = findNode(offset);
    if (oldHoverNode == clickNode) {
      if (clickNode != null) {
        click ? sendClickEvent(oldOffset, clickNode) : sendHoverEvent(oldOffset, clickNode);
      }
      return;
    }
    var oldNode = oldHoverNode;
    oldHoverNode = clickNode;
    if (oldNode != null) {
      sendHoverEndEvent(oldNode);
    }
    if (clickNode != null) {
      click ? sendClickEvent(oldOffset, clickNode) : sendHoverEvent(oldOffset, clickNode);
    }

    List<NodeDiff<N>> nl = [];

    if (oldNode != null) {
      var oldAttr = oldNode.toAttr();
      oldNode.removeState(ViewState.hover);
      onUpdateNodeStyle(oldNode);
      nl.add(NodeDiff(oldNode, oldAttr, oldNode.toAttr(), true));
    }

    if (clickNode != null) {
      var newAttr = clickNode.toAttr();
      clickNode.addState(ViewState.hover);
      onUpdateNodeStyle(clickNode);
      nl.add(NodeDiff(clickNode, newAttr, clickNode.toAttr(), false));
    }

    var animator = getAnimation(LayoutType.update, 2);
    if (animator == null) {
      onHandleHoverAndClickEnd(oldNode, clickNode);
      notifyLayoutUpdate();
      return;
    }
    if (nl.isNotEmpty) {
      onRunUpdateAnimation(nl, animator);
    }
    onHandleHoverAndClickEnd(oldNode, clickNode);
  }

  void onHandleHoverAndClickEnd(N? oldNode, N? newNode) {}

  void onUpdateNodeStyle(N node) {
    node.updateStyle(context, series);
  }

  void onRunUpdateAnimation(List<NodeDiff<N>> list, AnimatorOption animation) {
    List<ChartTween> tl = [];
    for (var diff in list) {
      var node = diff.node;
      var s = diff.startAttr;
      var e = diff.endAttr;
      var tween = ChartDoubleTween(option: animation);
      tween.addListener(() {
        var t = tween.value;
        node.itemStyle = AreaStyle.lerp(s.itemStyle, e.itemStyle, t);
        node.borderStyle = LineStyle.lerp(s.borderStyle, e.borderStyle, t);
        notifyLayoutUpdate();
      });
      tl.add(tween);
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  ///按照节点的绘制顺序排序
  void sortList(List<N> nodeList) {
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
  N? findNode(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverNode;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }

    ///这里倒序查找是因为当绘制顺序不一致时需要从最后查找
    var list = nodeList;
    for (int i = list.length - 1; i >= 0; i--) {
      var node = list[i];
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }
}
