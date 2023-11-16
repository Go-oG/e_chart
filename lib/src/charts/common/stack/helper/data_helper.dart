import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';

///处理二维坐标系下堆叠数据
class DataHelper<T extends StackItemData, P extends StackGroupData<T, P>> {
  late List<P> groupList;
  final CoordType coord;
  final int polarIndex;
  final Direction direction;
  final bool realSort;
  final Sort sort;
  final int? sortCount;

  List<StackData<T, P>> dataList = [];
  Map<String, StackData<T, P>> _dataMap = {};

  AxisGroup<T, P>? _result;

  AxisGroup<T, P> get result {
    return _result!;
  }

  bool hasData(StackData<T, P> data) {
    return _dataMap.containsKey(data.id);
  }
  DataHelper(this.coord, this.polarIndex, List<P> list, this.direction, this.realSort, this.sort, this.sortCount) {
    if (coord != CoordType.grid && coord != CoordType.polar) {
      throw ChartError('only support Grid and Polar Coord');
    }
    this.groupList = [...list];
    if (realSort) {
      if (groupList.length > 1) {
        throw ChartError("当启用了实时排序后，只支持一个数据组");
      }
      if (groupList.isNotEmpty) {
        each(groupList, (group, p1) {
          int c = sortCount ?? -1;
          if (c <= 0) {
            c = group.data.length;
          }
          if (c > group.data.length) {
            c = group.data.length;
          }
          double defaultV = sort == Sort.desc ? double.maxFinite : double.minPositive;
          group.data.sort((a, b) {
            var ad = a.dataNull;
            var bd = b.dataNull;
            num ai = ad == null ? defaultV : ad.maxValue;
            num bi = bd == null ? defaultV : bd.maxValue;
            if (sort == Sort.desc) {
              return bi.compareTo(ai);
            }
            return ai.compareTo(bi);
          });
          if (c < group.data.length) {
            group.data.removeRange(c, group.data.length);
          }
        });
      }
    }
    this.dataList = [];
    this._dataMap = {};
    each(groupList, (group, p1) {
      each(group.data, (p0, p1) {
        this.dataList.add(p0);
        _dataMap[p0.id] = p0;
      });
    });
    _result = _parse();
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

  ///解析数据
  ///将给定数据解析为类似于栈的数据
  ///并保存相关的数据信息
  AxisGroup<T, P> _parse() {
    ///初始化数据的索引
    _initData(groupList);

    ///收集基本数值信息
    _groupValueMap = _collectGroupInfo(groupList);

    ///将数据安装使用的X坐标轴进行分割
    Map<AxisIndex, List<GroupNode<T, P>>> resultMap = _splitDataByAxis(groupList);

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
  void _initData(List<P> dataList) {
    Map<P, int> sortMap = {};
    each(dataList, (group, groupIndex) {
      if (!sortMap.containsKey(group)) {
        sortMap[group] = groupIndex;
      }
      each(group.data, (cd, i) {
        cd.dataIndex = i;
        cd.groupIndex = groupIndex;
        cd.styleIndex = groupIndex;
        cd.attr.parent = group;
        cd.attr.coord = coord;
      });
    });
  }

  ///将给定的数据按照其使用的坐标轴进行分割
  Map<AxisIndex, List<GroupNode<T, P>>> _splitDataByAxis(List<P> dataList) {
    Map<AxisIndex, List<P>> axisGroupMap = {};
    for (var group in dataList) {
      int mainAxisIndex;
      if (coord == CoordType.polar) {
        mainAxisIndex = polarIndex;
      } else {
        if (direction == Direction.vertical) {
          mainAxisIndex = group.domainAxis;
        } else {
          mainAxisIndex = group.valueAxis;
        }
      }
      if (mainAxisIndex < 0) {
        mainAxisIndex = 0;
      }
      AxisIndex index = AxisIndex(coord, mainAxisIndex);
      if (!axisGroupMap.containsKey(index)) {
        axisGroupMap[index] = [];
      }
      axisGroupMap[index]!.add(group);
    }

    Map<AxisIndex, List<GroupNode<T, P>>> resultMap = {};
    axisGroupMap.forEach((key, value) {
      resultMap[key] = _handleSingleAxis(key, value);
    });
    return resultMap;
  }

  ///处理单根坐标轴
  List<GroupNode<T, P>> _handleSingleAxis(AxisIndex axisIndex, List<P> list) {
    int barGroupCount = _computeMaxGroupCount(list);

    ///存放分组数据
    List<List<StackData<T, P>>> groupDataList = List.generate(barGroupCount, (index) => []);
    for (int i = 0; i < barGroupCount; i++) {
      for (var data in list) {
        if (i >= data.data.length) {
          break;
        }
        groupDataList[i].add(data.data[i]);
      }
    }
    List<GroupNode<T, P>> groupNodeList = List.generate(barGroupCount, (index) => GroupNode(axisIndex, index, []));

    ///合并数据
    each(groupDataList, (group, index) {
      GroupNode<T, P> groupNode = groupNodeList[index];

      ///<stackId>
      Map<String, List<StackData<T, P>>> stackMap = {};
      List<StackData<T, P>> singleNodeList = [];
      each(group, (data, p1) {
        if (data.dataIsNull) {
          return;
        }
        if (data.parent.isStack) {
          var stackId = data.parent.stackId!;
          List<StackData<T, P>> dl = stackMap[stackId] ?? [];
          stackMap[stackId] = dl;
          dl.add(data);
        } else {
          singleNodeList.add(data);
        }
      });

      stackMap.forEach((key, value) {
        ColumnNode<T, P> column = ColumnNode(groupNode, [], true);
        column.nodeList.addAll(value);
        each(value, (p0, p1) {
          p0.attr.parentNode = column;
        });

        groupNode.nodeList.add(column);
      });
      each(singleNodeList, (e, i) {
        ColumnNode<T, P> column = ColumnNode(groupNode, [], false);
        e.attr.parentNode = column;
        column.nodeList.add(e);
        groupNode.nodeList.add(column);
      });
    });

    ///排序
    for (var group in groupNodeList) {
      //排序孩子
      // for (var child in group.nodeList) {
      //   if (child.nodeList.length > 1) {
      //     child.nodeList.sort((a, b) {
      //       var ai = a.groupIndex;
      //       var bi = b.groupIndex;
      //       return ai.compareTo(bi);
      //     });
      //   }
      // }

      //排序自身
      // if (group.nodeList.length > 1) {
      //   group.nodeList.sort((a, b) {
      //     var ai = a.nodeList.first.groupIndex;
      //     var bi = b.nodeList.first.groupIndex;
      //     return ai.compareTo(bi);
      //   });
      // }
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
            int axisIndex = m.min(x ? node.parent.domainAxis : node.parent.valueAxis, 0);
            List<dynamic> dl = [];
            if (x != vertical) {
              dl.add(node.attr.up);
              dl.add(node.attr.down);
            } else {
              dl.add(x ? node.dataNull?.domain : node.dataNull?.value);
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
      List<DateTime> timeList = [];
      if (value.minTime != null) {
        timeList.add(value.minTime!);
      }
      if (value.maxTime != null) {
        timeList.add(value.maxTime!);
      }
      var info = infoMap[key];
      if (info == null) {
        infoMap[key] = ExtremeInfo(x, AxisIndex(coord, key), [], [], timeList);
      } else {
        info.timeExtreme = timeList;
      }
    });

    strMap.forEach((key, value) {
      Set<String> strSet = {};
      List<String> strList = [];
      each(value, (str, p1) {
        if (!strSet.contains(str)) {
          strList.add(str);
          strSet.add(str);
        }
      });
      var info = infoMap[key];
      if (info == null) {
        infoMap[key] = ExtremeInfo(x, AxisIndex(coord, key), [], strList, []);
      } else {
        info.strExtreme = strList;
      }
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
      StackData<T, P>? minV;
      StackData<T, P>? maxV;

      List<StackData<T, P>> nl = [];
      for (var data in group.data) {
        if (data.dataIsNull) {
          continue;
        }
        nl.add(data);

        if (minV == null || data.data.minValue < minV.data.minValue) {
          minV = data;
        }
        if (maxV == null || data.data.maxValue > maxV.data.maxValue) {
          maxV = data;
        }
      }

      StackData<T, P>? aveV;

      if (nl.isNotEmpty) {
        num v = sumBy(nl, (p0) => p0.data.aveValue) / nl.length;
        nl.sort((a, b) {
          return a.data.aveValue.compareTo(b.data.aveValue);
        });
        num diff = double.maxFinite;
        for (var d in nl) {
          if ((d.data.aveValue - v).abs() < diff) {
            aveV = d;
            diff = (d.data.aveValue - v).abs();
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

  void dispose() {
    _result?.dispose();
    _result = null;
    groupList = [];
  }
}

class ValueInfo<T extends StackItemData, P extends StackGroupData<T, P>> {
  final P group;
  StackData<T, P>? minData;
  StackData<T, P>? maxData;
  StackData<T, P>? aveData;

  ValueInfo(this.group, this.minData, this.maxData, this.aveData);
}
