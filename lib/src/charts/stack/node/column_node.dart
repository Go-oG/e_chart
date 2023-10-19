import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class ColumnNode<T extends StackItemData, P extends StackGroupData<T>> {
  final GroupNode<T, P> parentNode;
  List<SingleNode<T, P>> nodeList;
  final bool isStack;

  ColumnNode(this.parentNode, this.nodeList, this.isStack);

  ///布局过程中使用
  Rect rect = Rect.zero;
  Arc arc = Arc.zero;

  num getUp() {
    if (nodeList.isEmpty) {
      return 0;
    }
    return nodeList[nodeList.length - 1].up;
  }

  num getDown() {
    if (nodeList.isEmpty) {
      return 0;
    }
    return nodeList[0].down;
  }

  SingleNode<T, P>? getUpNode() {
    for (int i = nodeList.length - 1; i >= 0; i--) {
      var cn = nodeList[i];
      if (cn.originData != null) {
        return cn;
      }
    }
    return null;
  }

  SingleNode<T, P>? getDownNode() {
    for (var cn in nodeList) {
      if (cn.originData != null) {
        return cn;
      }
    }
    return null;
  }

  void mergeData() {
    if (nodeList.isEmpty) {
      return;
    }
    if (nodeList.length == 1) {
      var first = nodeList.first;
      var itemData = first.originData;
      if (itemData == null) {
        return;
      }
      first.up = itemData.maxValue;
      first.down = itemData.minValue;
      return;
    }

    List<SingleNode<T, P>> positiveList = [];
    List<SingleNode<T, P>> negativeList = [];
    List<SingleNode<T, P>> crossList = [];
    each(nodeList, (node, p1) {
      var itemData = node.originData;
      if (itemData == null) {
        return;
      }
      if (itemData.minValue >= 0) {
        positiveList.add(node);
      } else if (itemData.maxValue <= 0) {
        negativeList.add(node);
      } else {
        crossList.add(node);
      }
    });

    List<List<SingleNode<T, P>>> tmpList = [positiveList, crossList];
    for (var list in tmpList) {
      if (list.isEmpty) {
        continue;
      }
      var first = list.first;
      var firstData = first.originData!;
      num down = firstData.minValue;
      num up = firstData.maxValue;
      each(list, (node, p1) {
        node.up = up;
        node.down = down;
        down = up;
        up += (node.originData!.maxValue - node.originData!.minValue);
      });
    }

    if (negativeList.isNotEmpty) {
      var first = negativeList.first;
      var firstData = first.originData!;
      num up = firstData.maxValue;
      num down = firstData.minValue;
      each(negativeList, (node, p1) {
        node.up = up;
        node.down = down;
        up = down;
        down -= (node.originData!.maxValue - node.originData!.minValue);
      });
    }
  }

  void dispose() {
    nodeList = [];
  }
}
