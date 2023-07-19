import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import '../../../core/view_state.dart';
import '../../../model/index.dart';
import '../base_data.dart';
import 'column_node.dart';

///表示为系列数据
class GroupNode<T extends BaseItemData, P extends BaseGroupData<T>> with ViewStateProvider {
  final StackData<T, P> data;

  List<ColumnNode<T, P>> nodeList = [];

  GroupNode(this.data);

  ///二维坐标使用
  Rect rect = Rect.zero;

  ///极坐标使用
  Arc arc = Arc();

  DynamicData getX() {
    for (var list in nodeList) {
      for (var data in list.data.data) {
        var x = data.wrap.data?.x;
        if (x != null) {
          return x;
        }
      }
    }
    throw ChartError("无法找到对应的横坐标");
  }

  int getYAxisIndex() {
    int index = 0;
    for (var node in nodeList) {
      for (var d in node.nodeList) {
        return d.data.parent.yAxisIndex;
      }
    }
    return index;
  }
}
