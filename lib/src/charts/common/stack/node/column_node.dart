import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class ColumnNode<T extends StackItemData, P extends StackGroupData<T, P>> {
  final GroupNode<T, P> parentNode;
  List<StackData<T, P>> nodeList;
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

  StackData<T, P>? getUpNode() {
    for (int i = nodeList.length - 1; i >= 0; i--) {
      var cn = nodeList[i];
      if (cn.dataIsNotNull) {
        return cn;
      }
    }
    return null;
  }

  StackData<T, P>? getDownNode() {
    for (var cn in nodeList) {
      if (cn.dataIsNotNull) {
        return cn;
      }
    }
    return null;
  }

  void mergeData(bool stackIsPercent) {
    if (nodeList.isEmpty) {
      return;
    }
    if (nodeList.length == 1) {
      var first = nodeList.first;
      var itemData = first.dataNull;
      if (itemData == null) {
        return;
      }
      if (stackIsPercent) {
        ///单个占比百分百
        first.attr.up = 100;
        first.attr.down = 0;
      } else {
        first.attr.up = itemData.maxValue;
        first.attr.down = itemData.minValue;
      }
      return;
    }

    List<StackData<T, P>> positiveList = [];
    List<StackData<T, P>> negativeList = [];
    List<StackData<T, P>> crossList = [];
    each(nodeList, (node, p1) {
      var itemData = node.dataNull;
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
    num allValue = 0;
    if (stackIsPercent) {
      allValue = sumBy<StackData<T, P>>(positiveList, (p0) => p0.dataIsNull ? 0 : p0.data.subValue);
    }

    List<List<StackData<T, P>>> tmpList = [positiveList, crossList];
    for (var list in tmpList) {
      if (list.isEmpty) {
        continue;
      }
      if (stackIsPercent) {
        double dv = 0;
        each(list, (node, p1) {
          if (allValue > 0) {
            node.attr.down = 100 * dv;
            dv += node.data.subValue / allValue;
            if (dv > 1) {
              throw ChartError('Percent more than 1');
            }
            node.attr.up = 100 * dv;
          } else {
            node.attr.down = 0;
            node.attr.up = 0;
          }
        });
      } else {
        var first = list.first;
        var firstData = first.data;
        num down = firstData.minValue;
        num up = firstData.maxValue;
        each(list, (node, p1) {
          node.attr.up = up;
          node.attr.down = down;
          down = up;
          up += node.data.subValue;
        });
      }
    }

    if (stackIsPercent) {
      allValue = sumBy<StackData<T, P>>(positiveList, (p0) => p0.dataIsNull ? 0 : p0.data.maxValue - p0.data.minValue);
    }

    if (negativeList.isNotEmpty) {
      if (stackIsPercent) {
        double dv = 0;
        each(negativeList, (node, p1) {
          if (allValue <= 0) {
            node.attr.down = dv;
            dv += node.data.subValue / allValue;
            node.attr.up = 100 * dv;
          } else {
            node.attr.down = 0;
            node.attr.up = 0;
          }
        });
      } else {
        var first = negativeList.first;
        var firstData = first.data;
        num up = firstData.maxValue;
        num down = firstData.minValue;
        each(negativeList, (node, p1) {
          node.attr.up = up;
          node.attr.down = down;
          up = down;
          down -= (node.data.maxValue - node.data.minValue);
        });
      }
    }
  }

  void dispose() {
    nodeList = [];
  }

  int indexOf(StackData<T, P> data) {
    return nodeList.indexOf(data);
  }

  StackData<T, P> getAt(int index) => nodeList[index];
}
