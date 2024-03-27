import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointHelper extends LayoutHelper2<PointData, PointSeries> {
  PointHelper(super.context, super.view, super.series);

  RBush<PointData> rBush = RBush((p0) => p0.left, (p0) => p0.top, (p0) => p0.right, (p0) => p0.bottom);

  List<PointData> showNodeList = [];

  @override
  void doLayout(bool changed, LayoutType type) {
    subscribeAxisChangeEvent();
    super.doLayout(changed, type);
  }

  @override
  void onLayout(LayoutType type) {
    var oldList = dataSet;
    var newList = [...series.data];
    initDataIndexAndStyle(newList);
    var an = DiffUtil.diff(
      getAnimation(type, oldList.length + newList.length),
      oldList,
      newList,
      (dataList) => layoutData(dataList),
      (node, type) {
        if (type == DiffType.add) {
          return {'scale': 0};
        }
        return {'scale': node.symbol.scale};
      },
      (node, type) {
        if (type == DiffType.remove) {
          return {'scale': 0};
        }
        return {'scale': 1};
      },
      (data, s, e, t, type) {
        data.symbol.scale = lerpDouble(s['scale'], e['scale'], t)!;
      },
      (resultList, t) {
        dataSet = resultList;
        notifyLayoutUpdate();
      },
      onStart: () {
        inAnimation = true;
        var tmp = [...oldList, ...newList];
        rBush.clear();
        rBush.addAll(tmp);
        updateShowNodeList();
      },
      onEnd: () {
        inAnimation = false;
        rBush.clear();
        rBush.addAll(newList);
        updateShowNodeList();
      },
    );
    context.addAnimationToQueue(an);
  }

  @override
  void initDataIndexAndStyle(List<PointData> dataList, [bool updateStyle = true]) {
    each(dataList, (data, i) {
      data.dataIndex = i;
      data.styleIndex = i;
      if (updateStyle) {
        data.updateStyle(context, series);
      }
    });
  }

  void layoutData(List<PointData> nodeList) {
    if (CoordType.polar == series.coordType) {
      _layoutForPolar(nodeList, findPolarCoord());
      return;
    }
    if (CoordType.calendar == series.coordType) {
      _layoutForCalendar(nodeList, findCalendarCoord());
      return;
    }
    if (CoordType.grid == series.coordType) {
      _layoutForGrid(nodeList, findGridCoord());
      return;
    }
    Logger.w('暂不支持其它坐标系 ${series.coordType}');
  }

  void _layoutForCalendar(List<PointData> dataList, CalendarCoord coord) {
    for (var node in dataList) {
      DateTime t;
      if (node.domain is DateTime) {
        t = node.domain;
      } else if (node.value is DateTime) {
        t = node.value;
      } else {
        throw ChartError('x 或y 必须有一个是DateTime');
      }
      node.attr = coord.dataToPosition(t).center;
    }
  }

  void _layoutForPolar(List<PointData> dataList, PolarCoord coord) {
    for (var data in dataList) {
      var position = coord.dataToPosition(data.domain, data.value);
      data.attr = position.position;
    }
  }

  void _layoutForGrid(List<PointData> dataList, GridCoord coord) {
    for (var data in dataList) {
      var x = coord.dataToPoint(data.domainAxis, data.domain, true);
      var y = coord.dataToPoint(data.valueAxis, data.value, false);
      double ox;
      if (x.length == 1) {
        ox = x.first.dx;
      } else {
        ox = (x.first.dx + x.last.dx) / 2;
      }
      double oy;
      if (y.length == 1) {
        oy = y.first.dy;
      } else {
        oy = (y.first.dy + y.last.dy) / 2;
      }
      data.attr = Offset(ox, oy);
    }
  }

  @override
  void onSyncScroll(CoordType type, double scrollX, double scrollY) {
    if (type != CoordType.grid) {
      return;
    }
    view.scrollTo(scrollX, scrollY);
    updateShowNodeList();
  }

  void updateShowNodeList() async {
    var rect = view.selfViewPort;
    var list = rBush.search2(rect);
    sortList(list);
    showNodeList = list;
    notifyLayoutUpdate();
  }

  @override
  int getAnimatorCountLimit() {
    return showNodeList.length;
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (series.coordType == CoordType.grid ||
        series.coordType == CoordType.polar ||
        series.coordType == CoordType.calendar) {
      return;
    }

    view.translationX += diff.dx;
    view.translationY += diff.dy;
    updateShowNodeList();
    notifyLayoutUpdate();
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    List<PointData> oldList = [];
    List<PointData> newList = [];
    for (var diff in list) {
      diff.data.drawIndex = diff.old ? 0 : 100;
      if (diff.old) {
        oldList.add(diff.data);
      } else {
        newList.add(diff.data);
      }
    }
    sortList(showNodeList);
    List<ChartTween> tl = [];
    for (var diff in list) {
      var node = diff.data;
      var scale = diff.startAttr.symbolScale;
      var end = diff.old ? 1 : (1 + 8 / node.symbol.size.shortestSide);
      var tw = ChartDoubleTween(option: animation);
      tw.addListener(() {
        var t = tw.value;
        node.symbol.scale = lerpDouble(scale, end, t)!;
        node.itemStyle = AreaStyle.lerp(diff.startAttr.itemStyle, diff.endAttr.itemStyle, t);
        node.borderStyle = LineStyle.lerp(diff.startAttr.borderStyle, diff.endAttr.borderStyle, t);
        notifyLayoutUpdate();
      });
      tl.add(tw);
    }
    for (var t in tl) {
      t.start(context, true);
    }
  }

  @override
  PointData? findData(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverData;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    var rect = Rect.fromCenter(center: offset, width: 8, height: 8);
    var result = rBush.search2(rect);
    for (var p in result) {
      if (p.contains(offset)) {
        return p;
      }
    }
    return null;
  }

  @override
  void onAxisScroll(AxisScrollEvent event) {
    if (event.coordType != CoordType.grid || series.coordType != CoordType.grid) {
      return;
    }
    if (event.coordViewId != findGridCoord().id) {
      return;
    }
    updateShowNodeList();
    //  view.markDirty();
  }

  @override
  void onAxisChange(AxisChangeEvent event) {
    if (event.coordViewId != findGridCoord().id) {
      return;
    }
    onLayout(LayoutType.none);
  }
}
