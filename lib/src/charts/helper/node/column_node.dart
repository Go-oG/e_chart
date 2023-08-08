import 'dart:ui';
import '../../../model/index.dart';
import '../stack_data.dart';
import 'group_node.dart';
import 'single_node.dart';

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

  void mergeData() {
    num up = 0;
    for (int i = 0; i < nodeList.length; i++) {
      var cd = nodeList[i];
      var itemData = cd.data;
      if (itemData == null) {
        cd.up = up;
        continue;
      }
      if (i == 0) {
        if (strategy == StackStrategy.all ||
            strategy == StackStrategy.samesign ||
            (strategy == StackStrategy.positive && itemData.value > 0 && isStack) ||
            (strategy == StackStrategy.negative && itemData.value < 0 && isStack)) {
          up = itemData.value;
          cd.up = itemData.value;
          cd.down = 0;
        }
      } else {
        if (strategy == StackStrategy.all ||
            (strategy == StackStrategy.samesign && (itemData.value <= 0 && up <= 0 || (itemData.value >= 0 && up >= 0))) ||
            (strategy == StackStrategy.positive && itemData.value > 0) ||
            (strategy == StackStrategy.negative && itemData.value < 0)) {
          cd.down = up;
          cd.up = up + itemData.value;
          up = cd.up;
        }
      }
    }
  }
}
