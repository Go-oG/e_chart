import 'package:flutter/material.dart';

import '../../coord/grid/grid_child.dart';
import '../../coord/grid/grid_layout.dart';
import '../../core/view.dart';
import '../../model/dynamic_data.dart';
import '../../style/area_style.dart';
import '../../style/line_style.dart';
import 'candlestick_series.dart';

/// 单个K线图
class CandleStickView extends  ChartView implements GridChild {
  final CandleStickSeries series;

  CandleStickView(this.series);

  @override
  int get xAxisIndex => series.xAxisIndex;

  @override
  int get yAxisIndex => series.yAxisIndex;

  @override
  int get xDataSetCount => series.data.length;

  @override
  int get yDataSetCount => xDataSetCount;

  @override
  List<DynamicData> get xDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(DynamicData(element.time));
    }
    return dl;
  }

  @override
  List<DynamicData> get yDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(DynamicData(element.highest));
      dl.add(DynamicData(element.lowest));
    }
    return dl;
  }

  @override
  void onDraw(Canvas canvas) {
    GridLayout layout = context.findGridCoord();
    for (var element in series.data) {
      _drawNode(canvas, element, layout);
    }
  }

  void _drawNode(Canvas canvas, CandleStickData data, GridLayout layout) {
    AreaStyle areaStyle = series.styleFun.call(data, null)!;
    LineStyle lineStyle = series.lineStyleFun.call(data, null)!;
    DynamicData dd = DynamicData(data.time);
    Offset minCenter = layout.dataToPoint2(xAxisIndex, dd, yAxisIndex, DynamicData(data.lowest));

    Offset openCenter = layout.dataToPoint2(xAxisIndex, dd, yAxisIndex, DynamicData(data.open));
    Offset openLeft = openCenter.translate(-10, 0);
    Offset openRight = openCenter.translate(10, 0);

    Offset closeCenter = layout.dataToPoint2(xAxisIndex, dd, yAxisIndex, DynamicData(data.close));
    Offset closeLeft = closeCenter.translate(-10, 0);
    Offset closeRight = closeCenter.translate(10, 0);

    Offset maxCenter = layout.dataToPoint2(xAxisIndex, dd, yAxisIndex, DynamicData(data.highest));

    Path path = Path();

    path.moveTo(minCenter.dx, minCenter.dy);
    if (data.close >= data.open) {
      path.lineTo(openCenter.dx, openCenter.dy);
      path.moveTo(closeCenter.dx, closeCenter.dy);
      path.lineTo(maxCenter.dx, maxCenter.dy);
    } else {
      path.lineTo(closeCenter.dx, closeCenter.dy);
      path.moveTo(openCenter.dx, openCenter.dy);
      path.lineTo(maxCenter.dx, maxCenter.dy);
    }
    lineStyle.drawPath(canvas, mPaint, path);

    path.reset();
    path.moveTo(openLeft.dx, openLeft.dy);
    path.lineTo(openRight.dx, openRight.dy);
    path.lineTo(closeRight.dx, closeRight.dy);
    path.lineTo(closeLeft.dx, closeLeft.dy);
    path.close();
    areaStyle.drawPath(canvas, mPaint, path);
  }
}
