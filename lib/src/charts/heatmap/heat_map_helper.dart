import 'dart:ui';

import 'package:e_chart/e_chart.dart';


class HeatMapHelper extends LayoutHelper2<HeatMapData, HeatMapSeries> {
  HeatMapHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    var oldList = nodeList;
    var newList = [...series.data];
    initData(newList);
    var an = DiffUtil.diff<HeatMapData>(
      getAnimation(type, oldList.length + newList.length),
      oldList,
      newList,
      (dataList) => layoutNode(dataList),
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
        nodeList = dataList;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () => inAnimation = false,
    );
    addAnimationToQueue(an);
  }

  @override
  void initData(List<HeatMapData> dataList) {
    each(dataList, (data, p1) {
      data.dataIndex = p1;
    });
  }

  void layoutNode(List<HeatMapData> nodeList) {
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordType == CoordType.grid) {
      gridLayout = findGridCoord();
    } else {
      calendarLayout = findCalendarCoord();
    }
    for (var data in nodeList) {
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
      //文字
      var label = data.label.text;
      if (label.isNotEmpty) {
        data.label = TextDraw(label, LabelStyle.empty, TextDraw.offsetByRect(data.attr, data.labelAlign),
            align: TextDraw.alignConvert(data.labelAlign));
      } else {
        data.label = TextDraw.empty;
      }
    }
  }
}
