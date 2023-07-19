import 'dart:ui';

import 'package:e_chart/e_chart.dart';
class BoxplotGroupNode {
  final BoxplotGroup data;
  List<BoxplotNode> nodeList;
  BoxplotGroupNode(this.data,this.nodeList);

}

class BoxplotNode with ViewStateProvider{
  final BoxplotGroup parent;
  final BoxplotData data;

  BoxplotNode(this.parent,this.data);
  late Path path;
  late Path areaPath;
}