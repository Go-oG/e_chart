import 'dart:ui';

import 'package:flutter/cupertino.dart';


import '../../../model/enums/chart_type.dart';
import 'single _node.dart';
import 'value_info.dart';

class StackNode {
  final int index;
  final List<SingleNode> nodeList = [];
  Rect rect = Rect.zero;

  StackNode(this.index);

  void layoutChild(GlobalValue globalValue) {
    if (nodeList.isEmpty) {
      return;
    }

    List<SingleNode> barList=[];
    List<SingleNode> lineList=[];
    List<SingleNode> pointList=[];
    List<SingleNode> otherList=[];
    for (var ele in nodeList) {
      ChartType type=ele.groupData.type;
      if(type==ChartType.bar){
        barList.add(ele);
      }else if(type==ChartType.line){
        lineList.add(ele);
      }else if(type==ChartType.point){
        pointList.add(ele);
      }else{
        otherList.add(ele);
      }
    }


    List<SingleNode> sl=[];
    sl.addAll(barList);
    sl.addAll(lineList);
    sl.addAll(pointList);
    sl.addAll(otherList);


    SingleNode first = sl[0];
    ValueInfo axis = globalValue.axisMap[first.groupData.xAxisId]!;
    num axisMin = axis.min;
    num axisMax = axis.max;

    num up = first.up;
    for (int i = 1; i < sl.length; i++) {
      SingleNode node = sl[i];
      node.down = up;
      node.up = node.down + node.data.diff;
      up = node.up;
    }
    double height = rect.height;
    double width = rect.width;

    for (var node in sl) {
      double bottom = rect.bottom - (height * (node.down - axisMin) / (axisMax - axisMin));
      double top = rect.bottom - (height * (node.up - axisMin) / (axisMax - axisMin));
      SingleProps props = SingleProps();
      props.rect = Rect.fromLTRB(rect.left, top, rect.right, bottom);
      node.cur = props;
    }
  }

}
