import 'dart:ui';
import 'package:e_chart/e_chart.dart';


class ColumnNode<T extends StackItemData, P extends StackGroupData<T>> {
  final GroupNode<T, P> parentNode;
  final List<SingleNode<T, P>> nodeList;
  final bool isStack;
  final StackStrategy strategy;

  ColumnNode(this.parentNode, this.nodeList, this.isStack, this.strategy);

  ///布局过程中使用
  Rect rect = Rect.zero;
  Arc arc = Arc();

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
    num? up;
    final bool negative = strategy == StackStrategy.negative;
    final bool positive = strategy == StackStrategy.positive;
    final bool all = strategy == StackStrategy.all;
    final bool samesign = strategy == StackStrategy.samesign;

    for (int i = 0; i < nodeList.length; i++) {
      var cn = nodeList[i];
      var itemData = cn.originData;
      if (itemData == null) {
        continue;
      }
      bool minZero = itemData.minValue > 0;
      bool maxZero = itemData.maxValue < 0;
      if (up == null) {
        if (all || samesign || (positive && minZero && isStack) || (negative && maxZero && isStack)) {
          up = itemData.maxValue;
          cn.up = itemData.maxValue;
          cn.down = itemData.minValue;
        }
        continue;
      }
      bool sameZero = (itemData.maxValue <= 0 && up <= 0) || (itemData.minValue >= 0 && up >= 0);
      if (all || (samesign && sameZero) || (positive && minZero) || (negative && maxZero)) {
        if (negative || (samesign && up < 0)) {
          cn.up = up;
          cn.down = up + itemData.minValue;
          up = cn.down;
        } else {
          cn.down = up;
          cn.up = up + itemData.maxValue;
          up = cn.up;
        }
      }
    }
  }
}
