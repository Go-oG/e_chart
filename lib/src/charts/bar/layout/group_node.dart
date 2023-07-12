import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/stack_data.dart';

import 'column_node.dart';

///表示为系列数据
class GroupNode with ViewStateProvider {
  final StackGroup group;

  List<ColumnNode> nodeList = [];

  GroupNode(this.group);

  Rect rect = Rect.zero;

  DynamicData getX() {
    return nodeList[0].data.data[0].data.x;
  }
}
