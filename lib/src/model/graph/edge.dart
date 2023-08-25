import 'dart:ui';

import 'package:dart_dagre/dart_dagre.dart';

import 'graph_node.dart';

class Edge<T extends GraphNode> {
  final String id;
  final T source;
  final T target;

  num minLen;
  num labelOffset;
  LabelPosition labelPos;
  int index = 0;
  num weight;

  ///布局相关使用的参数(外界调用不应该改变相关的参数)
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;

  final List<Offset> points = [];

  Edge(
    this.id,
    this.source,
    this.target, {
    this.minLen = 1,
    this.labelOffset = 10,
    this.labelPos = LabelPosition.right,
    this.weight = 1,
  });

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Edge && other.id == id;
  }
}
