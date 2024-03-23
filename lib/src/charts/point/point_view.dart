import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';
import 'point_helper.dart';

class PointView extends CoordChildView<PointSeries, PointHelper>  {
  PointView(super.context, super.series);

  @override
  void onDraw(CCanvas canvas) {
    var list = layoutHelper.showNodeList;
    each(list, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
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
  dynamic getDimData(CoordType type, AxisDim dim, dynamic data) {
    var dd = data as PointData;
    if (type.isGrid()) {
      return (dim as GridAxisDim).isXAxis ? dd.domain : dd.value;
    }
    if (type.isPolar()) {
      return (dim as PolarAxisDim).isRadius ? dd.domain : dd.value;
    }
    return dim.index == 0 ? dd.domain : dd.value;
  }

  @override
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim) {
    throw UnimplementedError();
  }

  @override
  int getAxisDataCount(CoordType type, AxisDim dim) {
    return series.data.length;
  }

  @override
  Iterable<dynamic> getAxisExtreme(CoordType type, AxisDim axisDim) {
    if (axisDim is PolarAxisDim) {
      String index = axisDim.isRadius ? 'x0' : 'y0';
      return series.getExtremeHelper().getExtreme(index).getAllExtreme();
    }
    if (axisDim is GridAxisDim) {
      String index = axisDim.isXAxis ? 'x0' : 'y0';
      return series.getExtremeHelper().getExtreme(index).getAllExtreme();
    }
    return series.getExtremeHelper().getExtreme('x0').getAllExtreme();
  }

  @override
  Iterable<dynamic> getViewPortAxisExtreme(CoordType type, AxisDim axisDim, BaseScale<dynamic, num> scale) {
    List<dynamic> dl = [];
    each(layoutHelper.showNodeList, (data, p1) {
      dl.add(getDimData(type, axisDim, data));
    });
    return dl;
  }
}
