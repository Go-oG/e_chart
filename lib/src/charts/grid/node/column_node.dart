import 'dart:ui';

import 'package:e_chart/src/charts/grid/node/group_node.dart';
import '../../../model/index.dart';
import '../../../shape/arc.dart';
import '../base_data.dart';
import 'single_node.dart';

class ColumnNode<T extends BaseItemData, P extends BaseGroupData<T>> {
  final GroupNode<T, P> parent;
  final List<SingleNode<T, P>> nodeList;
  final bool isStack;
  final StackStrategy strategy;

  ColumnNode(this.parent, this.nodeList, this.isStack, this.strategy);

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
            (strategy == StackStrategy.positive && itemData.up > 0 && isStack) ||
            (strategy == StackStrategy.negative && itemData.up < 0 && isStack)) {
          up = itemData.up;
          cd.up = itemData.up;
          cd.down = itemData.down;
        }
      } else {
        if (strategy == StackStrategy.all ||
            (strategy == StackStrategy.samesign && (itemData.up <= 0 && up <= 0 || (itemData.up >= 0 && up >= 0))) ||
            (strategy == StackStrategy.positive && itemData.up > 0) ||
            (strategy == StackStrategy.negative && itemData.up < 0)) {
          cd.down = up;
          cd.up = up + (itemData.up - itemData.down);
          up = cd.up;
        }
      }
    }
  }
}
