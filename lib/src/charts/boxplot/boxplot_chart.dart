import 'dart:ui';

import '../../coord/grid/grid_child.dart';
import '../../coord/grid/grid_coord.dart';
import '../../core/view.dart';
import '../../model/dynamic_data.dart';
import '../../style/line_style.dart';
import 'boxplot_series.dart';

/// 单个盒须图
class BoxPlotView extends ChartView implements GridChild {
  final BoxplotSeries series;

  BoxPlotView(this.series);

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
      dl.add(element.x);
    }
    return dl;
  }

  @override
  List<DynamicData> get yDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(element.min);
      dl.add(element.max);
    }
    return dl;
  }

  @override
  void onDraw(Canvas canvas) {
    for (var element in series.data) {
      _drawNode(canvas, element);
    }
  }

  void _drawNode(Canvas canvas, BoxplotData data) {
    LineStyle? style = series.lineStyleFun.call(data);
    GridCoord layout = context.findGridCoord();

    Offset minCenter = layout.dataToPoint(xAxisIndex, data.x, yAxisIndex, data.min).topCenter;
    Offset minLeft = minCenter.translate(-10, 0);
    Offset minRight = minCenter.translate(10, 0);

    Offset downCenter = layout.dataToPoint(xAxisIndex, data.x, yAxisIndex, data.downAve4).topCenter;
    Offset downLeft = minCenter.translate(-10, 0);
    Offset downRight = minCenter.translate(10, 0);

    Offset middleCenter = layout.dataToPoint(xAxisIndex, data.x, yAxisIndex, data.downAve4).topCenter;
    Offset middleLeft = middleCenter.translate(-10, 0);
    Offset middleRight = middleCenter.translate(10, 0);

    Offset upAveCenter = layout.dataToPoint(xAxisIndex, data.x, yAxisIndex, data.upAve4).topCenter;
    Offset upAveLeft = upAveCenter.translate(-10, 0);
    Offset upAveRight = upAveCenter.translate(10, 0);

    Offset maxCenter = layout.dataToPoint(xAxisIndex, data.x, yAxisIndex, data.max).topCenter;
    Offset maxLeft = maxCenter.translate(-10, 0);
    Offset maxRight = maxCenter.translate(10, 0);

    Path path = Path();
    path.moveTo(minLeft.dx, minLeft.dy);
    path.lineTo(minRight.dx, minRight.dy);

    path.moveTo(minCenter.dx, minCenter.dy);
    path.lineTo(downCenter.dx, downCenter.dy);

    path.moveTo(downLeft.dx, downLeft.dy);
    path.lineTo(downRight.dx, downRight.dy);
    path.lineTo(upAveRight.dx, upAveRight.dy);
    path.lineTo(upAveLeft.dx, upAveLeft.dy);
    path.lineTo(downLeft.dx, downLeft.dy);

    path.moveTo(middleLeft.dx, middleLeft.dy);
    path.lineTo(middleRight.dx, middleRight.dy);

    path.moveTo(upAveCenter.dx, upAveCenter.dy);
    path.lineTo(maxCenter.dx, maxCenter.dy);

    path.moveTo(maxLeft.dx, maxLeft.dy);
    path.lineTo(maxRight.dx, maxRight.dy);
    style.drawPath(canvas, mPaint, path, true);
  }
}
