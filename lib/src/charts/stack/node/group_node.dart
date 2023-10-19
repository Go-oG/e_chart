import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///表示为系列数据
class GroupNode<T extends StackItemData, P extends StackGroupData<T>> with ViewStateProvider {
  final AxisIndex index;
  final List<ColumnNode<T, P>> nodeList;

  ///组索引(影响其位置)
  int groupIndex;

  GroupNode(this.index, this.groupIndex, this.nodeList);

  ///布局中使用的数据
  ///二维坐标使用
  Rect rect = Rect.zero;

  ///极坐标使用
  Arc arc = Arc();

  dynamic getXData() {
    var result = getXNodeNull();
    if (result != null) {
      return result.originData!.x;
    }
    throw ChartError("无法找到对应的横坐标");
  }

  dynamic getYData() {
    var result = getYNodeNull();
    if (result != null) {
      return result.originData!.y;
    }
    throw ChartError("无法找到对应的横坐标");
  }

  SingleNode<T, P>? getXNodeNull() {
    for (var list in nodeList) {
      for (var node in list.nodeList) {
        var x = node.originData?.x;
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
        var y = node.originData?.y;
        if (y != null) {
          return node;
        }
      }
    }
    return null;
  }

  int getYAxisIndex() {
    for (var list in nodeList) {
      for (var d in list.nodeList) {
        var index = d.parent.yAxisIndex;
        if (index < 0) {
          index = 0;
        }
        return index;
      }
    }
    return 0;
  }

  int getXAxisIndex() {
    for (var list in nodeList) {
      for (var d in list.nodeList) {
        var index = d.parent.xAxisIndex;
        if (index < 0) {
          index = 0;
        }
        return index;
      }
    }
    return 0;
  }

  void mergeData() {
    for (var col in nodeList) {
      col.mergeData();
    }
  }
}
