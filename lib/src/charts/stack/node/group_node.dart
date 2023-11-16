import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///表示为系列数据
class GroupNode<T extends StackItemData, P extends StackGroupData<T,P>> with StateProvider {
  AxisIndex index;
  List<ColumnNode<T, P>> nodeList;

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
      return result.data.x;
    }
    throw ChartError("无法找到对应的横坐标");
  }

  dynamic getYData() {
    var result = getYNodeNull();
    if (result != null) {
      return result.data.y;
    }
    throw ChartError("无法找到对应的横坐标");
  }

  StackData<T, P>? getXNodeNull() {
    for (var list in nodeList) {
      for (var node in list.nodeList) {
        var x = node.dataNull?.x;
        if (x != null) {
          return node;
        }
      }
    }
    return null;
  }

  StackData<T, P>? getYNodeNull() {
    for (var list in nodeList) {
      for (var node in list.nodeList) {
        var y = node.data.y;
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
        var index = d.parent.valueAxis;
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
        var index = d.parent.domainAxis;
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

  void dispose() {
    each(nodeList, (p0, p1) {
      p0.dispose();
    });
    nodeList = [];
  }
}
