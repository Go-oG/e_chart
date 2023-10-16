import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

import 'point_helper.dart';

class PointView extends CoordChildView<PointSeries, PointHelper> with PolarChild, CalendarChild, GridChild {
  PointView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var list = layoutHelper.showNodeList;
    Offset tr=layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(tr.dx, tr.dy);
    each(list, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  List getPolarExtreme(bool radius) {
    String index=radius?'x0':'y0';
    return series.getExtremeHelper().getExtreme(index).getAllExtreme();
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
