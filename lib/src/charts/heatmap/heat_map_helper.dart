import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class HeatMapHelper extends LayoutHelper2<HeatMapData, HeatMapSeries> {
  HeatMapHelper(super.context, super.view, super.series);

  final RBush<HeatMapData> _rBush = RBush.from((p0) => p0.attr);

  @override
  void onLayout(LayoutType type) {
    var oldList = dataSet;
    var newList = [...series.data];
    initDataIndexAndStyle(newList, false);
    var an = DiffUtil.diff<HeatMapData>(
      getAnimation(type, oldList.length + newList.length),
      oldList,
      newList,
      (dataList) => layoutData(dataList),
      (data, type) {
        if (type == DiffType.add) {
          return {'scale': 0};
        }
        return {'scale': data.symbol.scale};
      },
      (data, type) {
        if (type == DiffType.add || type == DiffType.update) {
          return {'scale': 1};
        }
        return {'scale': 0};
      },
      (data, s, e, t, type) {
        num ss = s['scale'];
        num es = e['scale'];
        data.symbol.scale = lerpDouble(ss, es, t)!;
      },
      (dataList, t) {
        dataSet = dataList;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () {
        dataSet = _rBush.search2(getViewPortRect());
        inAnimation = false;
      },
    );
    addAnimationToQueue(an);
  }

  void layoutData(List<HeatMapData> dataList) {
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordType == CoordType.grid) {
      gridLayout = findGridCoord();
    } else {
      calendarLayout = findCalendarCoord();
    }
    for (var data in dataList) {
      Rect? rect;
      if (gridLayout != null) {
        rect = gridLayout.dataToRect(0, data.x, 0, data.y);
      } else if (calendarLayout != null) {
        rect = calendarLayout.dataToPosition(data.x);
      }
      if (rect == null) {
        throw ChartError('无法布局 $gridLayout  $calendarLayout');
      }
      data.attr = rect;
      data.updateStyle(context, series);
      data.updateLabelPosition(context, series);
    }

    _rBush.clear();
    _rBush.addAll(dataList);
  }

  Offset getTranslation() {
    var type = series.coordType;
    if (type == CoordType.calendar) {
      return findCalendarCoord().translation;
    }
    return findGridCoord().translation;
  }

  @override
  HeatMapData? findData(Offset offset, [bool overlap = false]) {
    // TODO: implement findNode
    return super.findData(offset, overlap);
  }
}
