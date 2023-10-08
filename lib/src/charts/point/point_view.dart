import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

import 'point_helper.dart';

class PointView extends CoordChildView<PointSeries, PointHelper> with PolarChild, CalendarChild, GridChild {
  PointView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var list = layoutHelper.showNodeList;
    canvas.save();
    canvas.translate(translationX, translationY);
    each(list, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
    canvas.restore();
    debugPrint("绘制数:${list.length} 占比:${(100 * list.length / layoutHelper.nodeList.length).toStringAsFixed(2)}");
  }

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  List<dynamic> getAngleExtreme() {
    return series.getExtremeHelper().getExtreme('y0').getAllExtreme();
  }

  @override
  List<dynamic> getRadiusExtreme() {
    return series.getExtremeHelper().getExtreme('x0').getAllExtreme();
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    axisIndex = max([axisIndex, 0]).toInt();
    return series.getExtremeHelper().getExtreme(isXAxis ? 'x:$axisIndex' : 'y$axisIndex').getAllExtreme();
  }

  @override
  List<dynamic> getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    List<dynamic> dl = [];
    each(layoutHelper.showNodeList, (node, p1) {
      var data = node.data;
      var index = isXAxis ? node.group.xAxisIndex : node.group.yAxisIndex;
      if (index < 0) {
        index = 0;
      }
      if (index != axisIndex) {
        return;
      }

      if (isXAxis) {
        dl.add(data.x);
      } else {
        dl.add(data.y);
      }
    });
    return dl;
  }

  @override
  PointHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return PointHelper(context, this, series);
  }

  @override
  bool get useSingleLayer => false;
}
