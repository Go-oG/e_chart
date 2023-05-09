import 'dart:math' as math;

import 'package:xchart/src/model/enums/chart_type.dart';
import 'package:xutil/xutil.dart';

import '../bar_series.dart';
import 'group_node.dart';
import 'single _node.dart';
import 'stack_node.dart';
import 'value_info.dart';

///将给定数据转换成节点
///转换后每个GroupNode 相当于一个列节点集合
List<GroupNode> convertData(BarSeries series, List<GroupData> list) {
  List<GroupNode> nodeList = [];
  List<List<GroupData>> dataGroupList = mergeStackGroup(list);
  int maxLength = computeMaxLength(list);
  int index = 0;
  for (var ele in dataGroupList) {
    GroupNode groupNode = GroupNode(index);
    for (int i = 0; i < maxLength; i++) {
      StackNode stackNode = StackNode(i);
      for (var stackChild in ele) {
        List<SingleData> singleList = stackChild.data;
        if (i >= singleList.length) {
          continue;
        }
        SingleData singleData = singleList[i];
        stackNode.nodeList.add(SingleNode(series, stackChild, singleData));
      }
      groupNode.nodeList.add(stackNode);
    }
    nodeList.add(groupNode);
    index += 1;
  }
  return nodeList;
}

///返回list中type等于给定类型的数据
List<GroupNode> filterNode(List<GroupNode> list, ChartType type) {
  List<GroupNode> nodeList = [];
  // for (var ele in list) {
  //   if (ele.data.type == type) {
  //     nodeList.add(ele);
  //   }
  // }
  return nodeList;
}

///返回list中type不在给定类型中的数据
List<GroupNode> filterNodeNot(List<GroupNode> list, Iterable<ChartType> notInclude) {
  Set<ChartType> sets = Set.from(notInclude);
  List<GroupNode> nodeList = [];
  // for (var ele in list) {
  //   if (!sets.contains(ele.data.type)) {
  //     nodeList.add(ele);
  //   }
  // }
  return nodeList;
}

///将给定的数据按照stackId进行合并
///返回的结果里面去掉了非stack布局的数据
List<List<GroupData>> mergeStackGroup(List<GroupData> list) {
  Map<String, List<GroupData>> map = {};
  Map<String, GroupData> groupMap = {};
  for (var ele in list) {
    if (!ele.isStack) {
      groupMap[ele.id] = ele;
    } else {
      String stackId = ele.stackId;
      List<GroupData> nodeList = map[stackId] ?? [];
      map[stackId] = nodeList;
      nodeList.add(ele);
    }
  }

  List<List<GroupData>> resultList = [];

  for (var ele in list) {
    if (ele.isStack) {
      resultList.add(map[ele.stackId]!);
    } else {
      resultList.add([groupMap[ele.id]!]);
    }
  }
  return resultList;
}

///收集全局的数值信息
GlobalValue collectGlobalValue(List<GroupData> list) {
  GlobalValue globalValue = GlobalValue();
  int maxLength = computeMaxLength(list);

  /// group
  for (var ele in list) {
    List<num> minAndMax = extremes<SingleData>(ele.data, (p0) => p0.up);
    num aveValue = aveBuy<SingleData>(ele.data, (p0) => p0.up);
    num median = mediumBy<SingleData>(ele.data, (p0) => p0.up);
    globalValue.groupValueMap[ele.id] = ValueInfo(minAndMax[0], minAndMax[1], aveValue, median);
  }

  ///stack
  List<List<GroupData>> groupData = mergeStackGroup(list);
  Map<String, List<num>> stackMap = {};

  for (var ele in groupData) {
    if (ele.isEmpty) {
      continue;
    }
    GroupData first = ele[0];
    if (first.isNotStack) {
      continue;
    }
    List<num>? numList = stackMap[first.stackId];
    if (numList != null) {
      continue;
    }
    numList ??= [];
    stackMap[first.stackId] = numList;
    for (int i = 0; i < maxLength; i++) {
      double num = 0;
      for (var groupData in ele) {
        List<SingleData> singleDataList = groupData.data;
        if (singleDataList.length <= i) {
          continue;
        }
        SingleData singleData = singleDataList[i];
        num += singleData.up;
      }
      numList.add(num);
    }
  }
  stackMap.forEach((key, value) {
    List<num> minAndMax = extremes<num>(value, (p0) => p0);
    num aveValue = aveBuy<num>(value, (p0) => p0);
    num median = mediumBy<num>(value, (p0) => p0);
    globalValue.stackValueMap[key] = ValueInfo(minAndMax[0], minAndMax[1], aveValue, median);
  });

  Map<String, List<num>> axisMap = {};

  for (var ele in list) {
    String axId = ele.yAxisId;
    ValueInfo valueInfo = globalValue.groupValueMap[ele.id]!;
    List<num> axisList = axisMap[axId] ?? [0, 0, 0, 0];
    axisMap[axId] = axisList;
    axisList[0] = math.max(axisList[0], valueInfo.min);
    axisList[1] = math.max(axisList[1], valueInfo.max);
    axisList[2] = math.max(axisList[2], valueInfo.ave);
    axisList[3] = math.max(axisList[3], valueInfo.median);
  }

  axisMap.forEach((key, value) {
    globalValue.axisMap[key] = ValueInfo(value[0], value[1], value[2], value[3]);
  });
  return globalValue;
}


int computeMaxLength(List<GroupData> list) {
  int max = 0;
  for (var element in list) {
    if (element.data.length > max) {
      max = element.data.length;
    }
  }
  return max;
}
