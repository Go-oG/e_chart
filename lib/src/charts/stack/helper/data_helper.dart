import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/stack/model/extreme.dart';

import 'extreme_info.dart';

///处理二维坐标系下堆叠数据
class DataHelper<T extends StackItemData, P extends StackGroupData<T>, S extends ChartSeries> {
  final Context context;
  final List<P> _dataList;
  final S _series;
  final Direction direction;
  final bool realSort;
  final Sort sort;
  final Map<T, SingleNode<T, P>> _nodeMap = {};

  SingleNode<T, P>? findNode(T t) {
    return _nodeMap[t];
  }

  late AxisGroup<T, P> _result;

  AxisGroup<T, P> get result {
    return _result;
  }

  DataHelper(this.context, this._series, this._dataList, this.direction, this.realSort, this.sort) {
    _result = _parse();
    _result.groupMap.forEach((key, value) {
      for (var gn in value) {
        for (var cn in gn.nodeList) {
          for (var node in cn.nodeList) {
            if (node.originData != null) {
              _nodeMap[node.originData!] = node;
            }
          }
        }
      }
    });
  }

  ///存储坐标轴上的极值数据
  Map<AxisIndex, ExtremeInfo> _xAxisExtreme = {};
  Map<AxisIndex, ExtremeInfo> _yAxisExtreme = {};

  ExtremeInfo getExtreme(CoordType system, bool x, int axisIndex) {
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    var index = AxisIndex(system, axisIndex);
    var info = (x ? _xAxisExtreme : _yAxisExtreme)[index];
    return info ?? ExtremeInfo(x, index, [], [], []);
  }

  ///存储每个数据组的数值信息
  Map<P, ValueInfo<T, P>> _groupValueMap = {};

  ValueInfo<T, P>? getValueInfo(P p) {
    return _groupValueMap[p];
  }

  OriginInfo<T, P> _originInfo = OriginInfo({}, {});

  ///解析数据
  ///将给定数据解析为类似于栈的数据
  ///并保存相关的数据信息
  AxisGroup<T, P> _parse() {
    _groupValueMap = _collectGroupInfo(_dataList);

    ///解析原始数据信息
    _originInfo = _parseOriginInfo(_dataList);

    ///将数据安装使用的X坐标轴进行分割
    Map<AxisIndex, List<GroupNode<T, P>>> resultMap = _splitDataByAxis(_originInfo, _dataList);

    ///最后进行数据合并整理
    AxisGroup<T, P> group = AxisGroup(resultMap);
    group.mergeData(direction);
    _xAxisExtreme = _collectExtreme(group, true);
    _yAxisExtreme = _collectExtreme(group, false);
    return group;
  }

  ///解析数据的原始信息
  ///包括子数据-父数据映射关系、
  ///排序索引
  OriginInfo<T, P> _parseOriginInfo(List<P> dataList) {
    Map<P, int> sortMap = {};
    Map<P, Map<int, WrapData<T, P>>> dataMap = {};
    each(dataList, (group, groupIndex) {
      if (!sortMap.containsKey(group)) {
        sortMap[group] = groupIndex;
      }
      Map<int, WrapData<T, P>> childMap = dataMap[group] ?? {};
      dataMap[group] = childMap;
      each(group.data, (childData, i) {
        childMap[i] = WrapData(childData, group, groupIndex, i);
      });
    });
    return OriginInfo(sortMap, dataMap);
  }

  ///将给定的数据按照其使用的坐标轴进行分割
  ///对于竖直方向 X轴为主轴，水平方向 Y轴为主轴
  Map<AxisIndex, List<GroupNode<T, P>>> _splitDataByAxis(OriginInfo<T, P> originInfo, List<P> dataList) {
    Map<AxisIndex, List<P>> axisGroupMap = {};
    for (var group in dataList) {
      int mainAxisIndex;
      CoordType system;
      if (_series.coordType == CoordType.polar) {
        system = CoordType.polar;
        mainAxisIndex = _series.polarIndex;
      } else {
        system = CoordType.grid;
        if (direction == Direction.vertical) {
          mainAxisIndex = group.xAxisIndex;
        } else {
          mainAxisIndex = group.yAxisIndex;
        }
      }
      if (mainAxisIndex < 0) {
        mainAxisIndex = 0;
      }
      AxisIndex index = AxisIndex(system, mainAxisIndex);
      if (!axisGroupMap.containsKey(index)) {
        axisGroupMap[index] = [];
      }
      axisGroupMap[index]!.add(group);
    }

    Map<AxisIndex, List<GroupNode<T, P>>> resultMap = {};
    axisGroupMap.forEach((key, value) {
      resultMap[key] = _handleSingleAxis(key, value, originInfo);
    });
    return resultMap;
  }

  ///处理单根坐标轴
  List<GroupNode<T, P>> _handleSingleAxis(AxisIndex axisIndex, List<P> list, OriginInfo<T, P> originInfo) {
    int barGroupCount = _computeMaxGroupCount(list);

    ///存放分组数据
    List<List<InnerData<T, P>>> groupDataSetList = List.generate(barGroupCount, (index) => []);
    for (int i = 0; i < barGroupCount; i++) {
      for (var data in list) {
        if (i >= data.data.length) {
          continue;
        }
        groupDataSetList[i].add(InnerData(data.data[i], data));
      }
    }
    List<GroupNode<T, P>> groupNodeList = List.generate(barGroupCount, (index) => GroupNode(axisIndex, index, []));

    ///合并数据
    each(groupDataSetList, (group, index) {
      GroupNode<T, P> groupNode = groupNodeList[index];

      ///<stackId>
      Map<String, List<WrapData<T, P>>> singleNodeMap = {};

      List<WrapData<T, P>> singleNodeList = [];
      each(group, (innerData, p1) {
        var wrap = originInfo.dataMap[innerData.parent]![index];
        if (wrap == null) {
          return;
        }
        if (wrap.parent.isStack) {
          var stackId = wrap.parent.stackId!;
          List<WrapData<T, P>> dl = singleNodeMap[stackId] ?? [];
          singleNodeMap[stackId] = dl;
          dl.add(wrap);
        } else {
          singleNodeList.add(wrap);
        }
      });

      var coord = _series.coordType == CoordType.polar ? CoordType.polar : CoordType.grid;
      singleNodeMap.forEach((key, value) {
        ColumnNode<T, P> column = ColumnNode(groupNode, [], true);
        List<SingleNode<T, P>> dl = List.from(value.map((e) => SingleNode(coord, column, e, true)));
        column.nodeList.addAll(dl);
        groupNode.nodeList.add(column);
      });
      each(singleNodeList, (e, i) {
        ColumnNode<T, P> column = ColumnNode(groupNode, [], false);
        column.nodeList.add(SingleNode(coord, column, e, false));
        groupNode.nodeList.add(column);
      });
    });

    ///排序
    for (GroupNode group in groupNodeList) {
      //排序孩子
      for (var child in group.nodeList) {
        if (child.nodeList.length > 1) {
          child.nodeList.sort((a, b) {
            var ai = a.groupIndex;
            var bi = b.groupIndex;
            return ai.compareTo(bi);
          });
        }
      }
      //排序自身
      if (group.nodeList.length > 1) {
        group.nodeList.sort((a, b) {
          var ai = a.nodeList.first.groupIndex;
          var bi = b.nodeList.first.groupIndex;
          return ai.compareTo(bi);
        });
      }
    }

    if (realSort) {
      groupNodeList.sort((a, b) {
        var au = a.getXNodeNull()?.up ?? 0;
        var bu = b.getXNodeNull()?.up ?? 0;
        if (sort == Sort.desc) {
          return bu.compareTo(au);
        } else {
          return au.compareTo(bu);
        }
      });
      each(groupNodeList, (gn, i) {
        gn.nodeIndex = i;
      });
    }
    return groupNodeList;
  }

  ///收集极值信息
  ///极值信息应该为复合数据
  Map<AxisIndex, ExtremeInfo> _collectExtreme(AxisGroup<T, P> axisGroup, bool x) {
    Map<int, NumExtreme> numMap = {};
    Map<int, TimeExtreme> timeMap = {};
    Map<int, List<String>> strMap = {};
    bool vertical = direction == Direction.vertical;
    axisGroup.groupMap.forEach((key, value) {
      for (var group in value) {
        for (var column in group.nodeList) {
          for (var node in column.nodeList) {
            int axisIndex = m.min(x ? node.parent.xAxisIndex : node.parent.yAxisIndex, 0);
            List<dynamic> dl = [];
            if (x != vertical) {
              dl.add(node.up);
              dl.add(node.down);
            } else {
              dl.add(x ? node.originData?.x : node.originData?.y);
            }
            for (var data in dl) {
              if (data == null) {
                continue;
              }

              if (data is String) {
                var strList = strMap[axisIndex] ?? [];
                strMap[axisIndex] = strList;
                strList.add(data);
                continue;
              }
              if (data is num) {
                var extreme = numMap[axisIndex] ?? NumExtreme();
                numMap[axisIndex] = extreme;
                if (extreme.minValue == null || (data < extreme.minValue!)) {
                  extreme.minValue = data;
                }
                if (extreme.maxValue == null || (data > extreme.maxValue!)) {
                  extreme.maxValue = data;
                }
                continue;
              }
              if (data is DateTime) {
                var extreme = timeMap[axisIndex] ?? TimeExtreme();
                timeMap[axisIndex] = extreme;
                if (extreme.minTime == null || (data.isBefore(extreme.minTime!))) {
                  extreme.minTime = data;
                }
                if (extreme.maxTime == null || (data.isAfter(extreme.maxTime!))) {
                  extreme.maxTime = data;
                }
                continue;
              }
              throw ChartError("不支持的数据类型 ${data.runtimeType}");
            }
          }
        }
      }
    });
    Map<int, ExtremeInfo> infoMap = {};
    var coord = _series.coordType ?? CoordType.grid;
    numMap.forEach((key, value) {
      var info = infoMap[key] ?? ExtremeInfo(x, AxisIndex(coord, key), [], [], []);
      infoMap[key] = info;
      var v = value.minValue;
      if (v != null && v.isFinite) {
        info.numExtreme.add(v);
      }
      v = value.maxValue;
      if (v != null && v.isFinite) {
        info.numExtreme.add(v);
      }
    });
    timeMap.forEach((key, value) {
      var info = infoMap[key] ?? ExtremeInfo(x, AxisIndex(coord, key), [], [], []);
      infoMap[key] = info;
      var v = value.minTime;
      if (v != null) {
        info.timeExtreme.add(v);
      }
      v = value.maxTime;
      if (v != null) {
        info.timeExtreme.add(v);
      }
    });
    strMap.forEach((key, value) {
      var info = infoMap[key] ?? ExtremeInfo(x, AxisIndex(coord, key), [], [], []);
      infoMap[key] = info;
      info.strExtreme.addAll(value);
    });
    Map<AxisIndex, ExtremeInfo> rm = {};
    infoMap.forEach((key, value) {
      value.syncData();
      rm[value.axisIndex] = value;
    });
    return rm;
  }

  ///收集分组数值信息
  Map<P, ValueInfo<T, P>> _collectGroupInfo(List<P> list) {
    Map<P, ValueInfo<T, P>> map = {};
    for (var group in list) {
      if (group.data.isEmpty) {
        continue;
      }
      T? minV;
      T? maxV;

      List<T> nl = [];
      for (var data in group.data) {
        if (data == null) {
          continue;
        }
        nl.add(data);
        if (minV == null || data.minValue < minV.minValue) {
          minV = data;
        }
        if (maxV == null || data.maxValue > maxV.maxValue) {
          maxV = data;
        }
      }

      T? aveV;
      if (nl.isNotEmpty) {
        num v = sumBy(nl, (p0) => p0.aveValue) / nl.length;
        nl.sort((a, b) {
          return a.aveValue.compareTo(b.aveValue);
        });
        num diff = double.maxFinite;
        for (var d in nl) {
          if ((d.aveValue - v).abs() < diff) {
            aveV = d;
            diff = (d.aveValue - v).abs();
          }
        }
      }
      map[group] = ValueInfo(group, minV, maxV, aveV);
    }
    return map;
  }

  ///计算最大的group数
  int _computeMaxGroupCount(List<P> list) {
    int max = 0;
    for (P data in list) {
      if (data.data.length > max) {
        max = data.data.length;
      }
    }
    return max;
  }
}

class InnerData<T extends StackItemData, P extends StackGroupData<T>> {
  final T? data;
  final P parent;

  InnerData(this.data, this.parent);
}

class OriginInfo<T extends StackItemData, P extends StackGroupData<T>> {
  final Map<P, int> sortMap;
  final Map<P, Map<int, WrapData<T, P>>> dataMap;

  OriginInfo(this.sortMap, this.dataMap);
}

class ValueInfo<T extends StackItemData, P extends StackGroupData<T>> {
  final P group;
  T? minData;
  T? maxData;
  T? aveData;

  ValueInfo(this.group, this.minData, this.maxData, this.aveData);
}
