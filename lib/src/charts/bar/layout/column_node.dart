import 'dart:ui';

import 'package:e_chart/src/model/stack_data.dart';

import 'single _node.dart';

class ColumnNode {
  final StackColumn data;
  List<SingleNode> nodeList = [];

  Rect rect = Rect.zero;

  ColumnNode(this.data);

  num getUp() {
    return nodeList[nodeList.length - 1].data.up;
  }

  num getDown() {
    return nodeList[0].data.down;
  }
}
