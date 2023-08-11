import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///表示为系列数据
class GroupNode<T extends StackItemData, P extends StackGroupData<T>> with ViewStateProvider {
  final AxisIndex index;
  int nodeIndex;
  final List<ColumnNode<T, P>> nodeList;

  GroupNode(this.index, this.nodeIndex, this.nodeList);

  ///布局中使用的数据
  ///二维坐标使用
  Rect rect = Rect.zero;

  ///极坐标使用
  Arc arc = Arc();

  dynamic getXData() {
    var result = getXNodeNull();
    if (result != null) {
      return result.data!.x;
    }
    throw ChartError("无法找到对应的横坐标");
  }

  dynamic getYData() {
    var result = getYNodeNull();
    if (result != null) {
      return result.data!.y;
    }
    throw ChartError("无法找到对应的横坐标");
  }

  SingleNode<T, P>? getXNodeNull() {
    for (var list in nodeList) {
      for (var node in list.nodeList) {
        var x = node.data?.x;
        if (x != null) {
          return node;
        }
      }
    }
    return null;
  }

  SingleNode<T, P>? getYNodeNull() {
    for (var list in nodeList) {
      for (var node in list.nodeList) {
        var y = node.data?.y;
        if (y != null) {
          return node;
        }
      }
    }
    return null;
  }

  int getYAxisIndex() {
    int index = 0;
    for (var list in nodeList) {
      for (var d in list.nodeList) {
        return d.parent.yAxisIndex;
      }
    }
    return index;
  }

  int getXAxisIndex() {
    int index = 0;
    for (var list in nodeList) {
      for (var d in list.nodeList) {
        return d.parent.xAxisIndex;
      }
    }
    return index;
  }

  void mergeData() {
    for (var col in nodeList) {
      col.mergeData();
    }
  }
}
