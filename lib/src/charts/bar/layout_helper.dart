import 'package:flutter/material.dart';
import '../../ext/int_ext.dart';
import '../../model/enums/direction.dart';
import 'bar_series.dart';
import 'layout/data_util.dart';
import 'layout/group_node.dart';
import 'layout/stack_node.dart';
import 'layout/value_info.dart';

/// 辅助柱状图、折线图等二维坐标系进行布局
class LayoutHelper {
  final BarSeries series;
  Rect rect = Rect.zero;

  ///存储坐标轴对应的视图窗口
  late List<GroupNode> nodeList;

  late GlobalValue globalValue;

  ValueNotifier<IntWrap> notifier;

  LayoutHelper(this.series, this.notifier) {
    parseData(series.data);
  }

  /// 解析相关的数据转换为Node
  void parseData(List<BarGroupData> dataList) {
    nodeList = convertData(series, dataList);
    globalValue = collectGlobalValue(dataList);
  }

  ///开始布局
  void layout(double left, double top, double right, double bottom) {
    rect = Rect.fromLTRB(left, top, right, bottom);
    final double viewSize = series.direction == Direction.vertical ? width : height;
    final int maxLength = computeMaxLength(series.data);
    final num itemWidth = viewSize / maxLength;
    final int stackCount = nodeList.length;
    final double childWidth = itemWidth / stackCount;
    for (int i = 0; i < maxLength; i++) {
      double leftOffset = itemWidth * i + rect.left;
      int nodeCount = nodeList.length;
      for (int j = 0; j < nodeCount; j++) {
        GroupNode groupNode = nodeList[j];
        if (groupNode.nodeList.length <= i) {
          continue;
        }
        StackNode stackNode = groupNode.nodeList[i];
        stackNode.rect = Rect.fromLTWH(leftOffset + j * childWidth, rect.top, childWidth, rect.height);
        stackNode.layoutChild(globalValue);
      }
    }
  }

  //===========================================
  double get width => rect.width;

  double get height => rect.height;
}
