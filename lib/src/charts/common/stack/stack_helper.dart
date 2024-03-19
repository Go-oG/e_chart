import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///用于处理堆叠数据的布局帮助者
///一般用于笛卡尔坐标系和极坐标系的布局
///需要支持部分布局
abstract class StackHelper<T extends StackItemData, P extends StackGroupData<T, P>, S extends StackSeries<T, P>>
    extends LayoutHelper2<StackData<T, P>, S> {
  List<MarkPointNode> markPointList = [];

  List<MarkLineNode> markLineList = [];

  StackHelper(super.context, super.view, super.series);

  @override
  void dispose() {
    markLineList = [];
    markPointList = [];
    super.dispose();
  }

  @override
  void doLayout(bool changed, LayoutType type) {
    subscribeBrushEvent();
    subscribeLegendEvent();
    super.doLayout(changed, type);
  }

  @override
  void onLayout(LayoutType type) {
    var helper = series.getHelper(context);
    var oldList = dataSet;
    List<StackData<T, P>> newNodeList = onComputeNeedLayoutData(helper);
    newNodeList.removeWhere((element) => element.dataIsNull);
    var an = DiffUtil.diff(
      getAnimation(type, newNodeList.length),
      oldList,
      newNodeList,
      (dataList) => onLayoutData(helper, dataList, type),
      (data, type) => {'anNode': onCreateAnimatorNode(data, type, true)},
      (data, type) => {'anNode': onCreateAnimatorNode(data, type, false)},
      (data, s, e, t, type) {
        onAnimatorUpdate(data, t, s['anNode'], e['anNode']);
      },
      (dataList, t) {
        dataSet = dataList;
        onAnimatorUpdateEnd(dataSet, t);
        notifyLayoutUpdate();
      },
      onStart: () {
        inAnimation = true;
      },
      onEnd: () {
        inAnimation = false;
      },
      removeDataCall: (removeList) {
        each(removeList, (p0, p1) {
          if (!helper.hasData(p0)) {
            p0.dispose();
          }
        });
      },
    );
    addAnimationToQueue(an);
  }

  void onLayoutData(DataHelper<T, P> helper, List<StackData<T, P>> dataList, LayoutType type) {
    Set<GroupNode<T, P>> groupNodeSet = Set.from(dataList.map((e) => e.parentNode.parentNode));
    Map<AxisIndex, List<GroupNode<T, P>>> axisNodeMap = {};
    each(groupNodeSet, (groupNode, p1) {
      List<GroupNode<T, P>> groupList = axisNodeMap[groupNode.index] ?? [];
      axisNodeMap[groupNode.index] = groupList;
      groupList.add(groupNode);
    });

    ///对节点进行排序(同时也处理实时排序)
    axisNodeMap.forEach((key, vList) {
      vList.sort((a, b) {
        return a.groupIndex.compareTo(b.groupIndex);
      });
    });

    ///开始布局
    for (var ele in axisNodeMap.values) {
      ///布局Group
      for (var groupNode in ele) {
        if (groupNode.nodeList.isEmpty) {
          continue;
        }

        ///布局当前组的位置
        onLayoutGroup(groupNode, type);

        ///布局组里面的列
        onLayoutColumn(helper.result, groupNode, type);

        ///布局列里面的节点
        for (var cn in groupNode.nodeList) {
          onLayoutNode(cn, type);
        }
      }
    }

    each(dataList, (p0, p1) {
      p0.updateStyle(context, series);
      p0.updateLabelPosition(context, series);
    });
    layoutMarkPointAndLine(helper, series.data, dataList);
    onLayoutDataEnd(helper, dataList, type);
  }

  void onLayoutDataEnd(DataHelper<T, P> helper, List<StackData<T, P>> dataList, LayoutType type) {}

  ///返回当前需要布局的数据
  List<StackData<T, P>> onComputeNeedLayoutData(DataHelper<T, P> helper) {
    if (coordSystem != CoordType.grid) {
      return helper.dataList;
    }

    List<StackData<T, P>> resultList = [];
    if (series.realtimeSort) {
      ///对于realtimeSort 其必须只能为一组数据
      resultList.addAll(helper.dataList);
      int sortCount = series.sortCount ?? 2 ^ 32 - 1;
      if (sortCount <= 0) {
        sortCount = 2 ^ 32 - 1;
      }
      if (resultList.length > sortCount) {
        resultList.removeRange(sortCount, resultList.length);
      }
      return resultList;
    }

    var coord = findGridCoord();
    Map<int, RangeInfo> infoMap = {};
    helper.result.storeMap.forEach((key, value) {
      var index = key.axisIndex;
      var info = infoMap[key.axisIndex] ?? coord.getAxisViewportDataRange(key.axisIndex, series.isVertical);
      infoMap[index] = info;
      var list = value.getDataByRange(info);
      resultList.addAll(list);
    });
    return resultList;
  }

  ///实现该方法从而布局单个Group(不需要布局其孩子)
  void onLayoutGroup(GroupNode<T, P> groupNode, LayoutType type);

  ///布局GroupNode的孩子(ColumnNode)位置
  void onLayoutColumn(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, LayoutType type);

  ///布局ColumnNode的孩子的位置
  void onLayoutNode(ColumnNode<T, P> columnNode, LayoutType type);

  ///布局MarkLine和MarkPoint
  void layoutMarkPointAndLine(DataHelper<T, P> helper, List<P> groupList, List<StackData<T, P>> newNodeList) {
    if (series.markPoint == null &&
        series.markLine == null &&
        series.markPointFun == null &&
        series.markLineFun == null) {
      markLineList = [];
      markPointList = [];
      return;
    }
    final List<MarkPointNode> mpnl = [];
    final List<MarkLineNode> mlnl = [];
    for (var group in groupList) {
      if (group.data.isEmpty) {
        continue;
      }
      var mpl = series.getMarkPoint(group);
      var mll = series.getMarkLine(group);
      if (mpl.isEmpty && mll.isEmpty) {
        continue;
      }
      //markPoint
      for (var mp in mpl) {
        var node = onLayoutMarkPoint(helper, mp, group);
        if (node != null) {
          mpnl.add(node);
        }
      }
      //markLine
      for (var ml in mll) {
        var s = onLayoutMarkPoint(helper, ml.start, group);
        var e = onLayoutMarkPoint(helper, ml.end, group);
        if (s != null && e != null) {
          mlnl.add(MarkLineNode(ml, s, e));
        } else {
          if (s != null) {
            mpnl.add(s);
          }
          if (e != null) {
            mpnl.add(e);
          }
        }
      }
    }

    void hc() {
      layoutMarkPointAndLine(helper, series.data, dataSet);
    }

    for (var mpn in mpnl) {
      mpn.markPoint.addListener(hc);
    }
    for (var mln in mlnl) {
      mln.line.addListener(hc);
    }
    markPointList = mpnl;
    markLineList = mlnl;
  }

  MarkPointNode? onLayoutMarkPoint(DataHelper<T, P> helper, MarkPoint markPoint, P group) {
    var valueType = markPoint.data.valueType;
    if (markPoint.data.data != null) {
      var dl = markPoint.data.data!;
      if (dl.length < 2) {
        throw ChartError("in GridCoord or PolarCoord ,markPoint.data must is null or length >2");
      }
      var node = MarkPointNode(markPoint, dl[1]);
      if (coordSystem == CoordType.polar) {
        var position = findPolarCoord().dataToPosition(dl[0], dl[1]);
        var angle = (position.angle.first + position.angle.last) / 2;
        var radius = (position.radius.first + position.radius.last) / 2;
        node.offset = circlePoint(radius, angle, position.center);
      } else {
        var gridCoord = findGridCoord();
        List<Offset> xl = gridCoord.dataToPoint(group.domainAxis, dl[0], true);
        List<Offset> yl = gridCoord.dataToPoint(group.valueAxis, dl[1], false);
        double dx, dy;
        if (xl.length == 1) {
          dx = xl[0].dx;
        } else {
          var xAxis = gridCoord.getAxis(group.domainAxis, true);
          if (xAxis.isCategoryAxis && xAxis.categoryCenter) {
            dx = (xl[0].dx + xl[1].dx) / 2;
          } else {
            dx = xl[0].dx;
          }
        }
        if (yl.length == 1) {
          dy = yl[0].dy;
        } else {
          var yAxis = gridCoord.getAxis(group.valueAxis, false);
          if (yAxis.isCategoryAxis && yAxis.categoryCenter) {
            dy = (yl[0].dy + yl[1].dy) / 2;
          } else {
            dy = yl[0].dy;
          }
        }
        node.offset = Offset(dx, dy);
      }
      return node;
    }

    if (valueType != null) {
      var info = series.getHelper(context).getValueInfo(group);
      if (info == null) {
        return null;
      }
      StackData<T, P>? data;
      if (valueType == ValueType.min && info.minData != null) {
        data = info.minData;
      } else if (valueType == ValueType.max && info.maxData != null) {
        data = info.maxData;
      } else if (valueType == ValueType.ave && info.aveData != null) {
        data = info.aveData;
      }
      if (data == null) {
        return null;
      }

      var node = MarkPointNode(markPoint, data);
      if (coordSystem == CoordType.polar) {
        var arc = data.arc;
        node.offset = circlePoint(arc.outRadius, arc.centerAngle(), arc.center);
      } else {
        if (data.up >= 0) {
          node.offset = data.rect.topCenter;
        } else {
          node.offset = data.rect.bottomCenter;
        }
      }
      return node;
    }
    final data = markPoint.data.coord;
    if (data != null) {
      bool vertical = series.direction == Direction.vertical;
      MarkPointNode node;
      if (coordSystem == CoordType.polar) {
        var coord = findPolarCoord();
        var radius = coord.getRadius();
        var x = data[0].convert(radius.last);
        var xr = x / radius.last;
        var y = data[1].convert(coord.getSweepAngle());
        var yr = y / coord.getSweepAngle();
        var dd = vertical ? coord.getScale(true).convertRatio(yr) : coord.getScale(false).convertRatio(xr);
        node = MarkPointNode(markPoint, dd);
        node.offset = Offset(x, y);
      } else {
        var coord = findGridCoord();
        final xIndex = group.domainAxis;
        final yIndex = group.valueAxis;
        var x = data[0].convert(coord.getAxisLength(xIndex, true));
        var xr = x / coord.getAxisLength(xIndex, true);
        var y = data[1].convert(coord.getAxisLength(yIndex, false));
        var yr = y / coord.getAxisLength(yIndex, false);
        var dd =
            vertical ? coord.getScale(yIndex, false).convertRatio(yr) : coord.getScale(xIndex, true).convertRatio(xr);
        node = MarkPointNode(markPoint, dd);
        node.offset = Offset(x, y);
      }
      return node;
    }
    return null;
  }

  ///==============动画相关函数===============
  bool needRunAnimator(LayoutType type) {
    if (type == LayoutType.none) {
      return false;
    }
    return getAnimation(type) != null;
  }

  ///创建动画节点
  StackAnimatorNode onCreateAnimatorNode(StackData<T, P> node, DiffType diffType, bool isStart);

  void onAnimatorStart(List<StackData<T, P>> nodeList) {}

  void onAnimatorUpdate(StackData<T, P> node, double t, StackAnimatorNode startStatus, StackAnimatorNode endStatus) {
    var s = startStatus.rect;
    var e = endStatus.rect;
    if (s == null || e == null) {
      return;
    }
    node.rect = Rect.lerp(s, e, t)!;

    node.attr.position = node.rect.center;
    if (series.realtimeSort && series.dynamicLabel) {
      var axisIndex = series.isVertical ? node.parent.valueAxis : node.parent.domainAxis;
      var pos = series.isVertical ? node.rect.top : node.rect.right;
      var s = findGridCoord().pxToData(axisIndex, series.isHorizontal, pos);
      node.attr.dynamicLabel = s;
    } else {
      node.attr.dynamicLabel = null;
    }
    node.updateLabelPosition(context, series);
  }

  void onAnimatorUpdateEnd(List<StackData<T, P>> nodeList, double t) {}

  void onAnimatorEnd(List<StackData<T, P>> nodeList) {}

  //===========动画结束=========

  dynamic getNodeUpValue(StackData<T, P> node) {
    return node.up;
  }

  dynamic getNodeDownValue(StackData<T, P> node) {
    return node.down;
  }

  ///=======其它函数======
  ///获取指定坐标轴上的极值数据
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    CoordType system = CoordType.grid;
    if (series.coordType == CoordType.polar) {
      system = CoordType.polar;
    }
    AxisType type;
    if (series.coordType == CoordType.polar) {
      var coord = findPolarCoord();
      type = isXAxis ? coord.radiusAxisType : coord.angleAxisType;
    } else {
      var coord = findGridCoord();
      type = coord.getAxisType(axisIndex, isXAxis);
    }
    var extreme = series.getHelper(context).getExtreme(system, isXAxis, axisIndex);
    if (type == AxisType.category) {
      return extreme.strExtreme;
    }
    if (type == AxisType.time) {
      return extreme.timeExtreme;
    }
    return extreme.numExtreme;
  }

  ///获取当前显示窗口内的极值数据
  List<dynamic> getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    List<dynamic> dl = [];
    List<StackData<T, P>> list = dataSet;
    if (series.realtimeSort) {
      list = List.from(dataSet);
      list.sort((a, b) {
        if (series.sort == Sort.asc) {
          return a.up.compareTo(b.up);
        }
        return b.up.compareTo(a.up);
      });
    }

    each(list, (value, i) {
      if (value.dataIsNull) {
        return;
      }
      var index = isXAxis ? value.parent.domainAxis : value.parent.valueAxis;
      if (index < 0) {
        index = 0;
      }
      if (index != axisIndex) {
        return;
      }
      if (series.isVertical && !isXAxis || (!series.isVertical && isXAxis)) {
        dl.add(value.data.minValue);
        dl.add(value.data.maxValue);
      } else {
        if (isXAxis) {
          dl.add(value.data.x);
        } else {
          dl.add(value.data.y);
        }
      }
    });

    return dl;
  }

  ///==========Brush相关的=============

  @override
  void onBrushUpdate(BrushUpdateEvent event) {
    onHandleBrush(event.areas);
  }

  @override
  void onBrushEnd(BrushEndEvent event) {
    onHandleBrush(event.areas);
  }

  void onHandleBrush(List<BrushArea> areas) {
    each(dataSet, (node, i) {
      bool has = false;
      for (var area in areas) {
        if (coordSystem == CoordType.grid && area.path.overlapRect(node.rect)) {
          has = true;
          break;
        }
        if (coordSystem == CoordType.polar && node.attr.arc.toPath().overlapRect(area.bounds)) {
          has = true;
          break;
        }
      }
      if (has) {
        has = node.updateStatus(context, [ViewState.disabled], [ViewState.selected]);
      } else {
        has = node.updateStatus(context, [ViewState.selected], [ViewState.disabled]);
      }
      if (has) {
        node.updateStyle(context, series);
      }
    });
    notifyLayoutUpdate();
  }

  CoordType get coordSystem;

  @override
  StackData<T, P>? findData(Offset offset, [bool overlap = false]) {
    for (var ele in dataSet) {
      if (ele.contains(offset)) {
        return ele;
      }
    }
    for (var ele in series.getHelper(context).dataList) {
      if (ele.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  Offset getTranslation() {
    var type = coordSystem;
    if (type == CoordType.polar) {
      return findPolarCoord().translation;
    }
    return findGridCoord().translation;
  }

  Offset getMaxTranslation() {
    var type = coordSystem;
    if (type == CoordType.polar) {
      return findPolarCoord().getMaxScroll();
    }
    return findGridCoord().getMaxScroll();
  }
}
