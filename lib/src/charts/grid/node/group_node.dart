import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import '../model/axis_index.dart';

///表示为系列数据
class GroupNode<T extends BaseItemData, P extends BaseGroupData<T>> with ViewStateProvider {
  final AxisIndex index;
  final List<ColumnNode<T, P>> nodeList;

  GroupNode(this.index, this.nodeList);

  ///二维坐标使用
  Rect rect = Rect.zero;

  ///极坐标使用
  Arc arc = Arc();

  DynamicData getX() {
    for (var list in nodeList) {
      for (var node in list.nodeList) {
        var x = node.data?.x;
        if (x != null) {
          return x;
        }
      }
    }
    throw ChartError("无法找到对应的横坐标");
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

  void mergeData() {
    for (var col in nodeList) {
      col.mergeData();
    }
  }


}
