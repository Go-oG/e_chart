import 'dart:math';

import 'package:e_chart/e_chart.dart';

abstract class StackView<T extends StackItemData, G extends StackGroupData<T, G>, S extends StackSeries<T, G>,
    L extends StackHelper<T, G, S>> extends CoordChildView<S, L> {
  StackView(super.context, super.series) {
    layoutParams = LayoutParams.matchAll();
  }

  bool get useSingleLayer {
    if (series.realtimeSort || series.dynamicRange || series.dynamicLabel) {
      return false;
    }
    return true;
  }

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    layoutHelper.doMeasure(widthSpec, heightSpec);
    return super.onMeasure(widthSpec, heightSpec);
  }

  @override
  void onDraw(CCanvas canvas) {
    onDrawGroupBk(canvas);
    onDrawBar(canvas);
    onDrawBarLabel(canvas);
    onDrawMark(canvas);
  }

  void onDrawGroupBk(CCanvas canvas) {}

  void onDrawBar(CCanvas canvas) {}

  void onDrawBarLabel(CCanvas canvas) {}

  /// 绘制标记线和点
  void onDrawMark(CCanvas canvas) {
    var markLineFun = series.markLineFun;
    var markPointFun = series.markPointFun;
    var markPoint = series.markPoint;
    var markLine = series.markLine;
    if (markLineFun == null && markPointFun == null && markPoint == null && markLine == null) {
      return;
    }

    if (markLineFun != null || markLine != null) {
      each(layoutHelper.markLineList, (ml, i) {
        ml.line.draw(canvas, mPaint, ml.start.offset, ml.end.offset);
      });
    }
    each(layoutHelper.markPointList, (mp, i) {
      mp.markPoint.draw(canvas, mPaint, mp.offset);
    });
  }

  @override
  int allocateDataIndex(int index) {
    each(series.data, (p0, p1) {
      p0.styleIndex = p1 + index;
    });
    return series.data.length;
  }

  @override
  Iterable<dynamic> getAxisExtreme(CoordType type, AxisDim axisDim) {
    if (type.isPolar()) {
      return layoutHelper.getAxisExtreme(axisDim.index, (axisDim as PolarAxisDim).isRadius);
    } else {
      return layoutHelper.getAxisExtreme(axisDim.index, (axisDim as GridAxisDim).isXAxis);
    }
  }

  @override
  Iterable<dynamic> getViewPortAxisExtreme(CoordType type, AxisDim axisDim, BaseScale<dynamic, num> scale) {
    if (type.isPolar()) {
      return layoutHelper.getViewPortAxisExtreme(axisDim.index, (axisDim as PolarAxisDim).isRadius, scale);
    } else {
      return layoutHelper.getViewPortAxisExtreme(axisDim.index, (axisDim as GridAxisDim).isXAxis, scale);
    }
  }

  @override
  CoordInfo getEmbedCoord() {
    var type = series.coordType;
    if (type == CoordType.polar) {
      return CoordInfo(CoordType.polar, max(0, series.polarIndex));
    } else {
      return CoordInfo(CoordType.grid, max(0, series.gridIndex));
    }
  }

  @override
  int getAxisDataCount(CoordType type, AxisDim dim) {
    int count = 0;
    for (var data in series.data) {
      if (data.data.length > count) {
        count = data.data.length;
      }
    }
    return count;
  }

  @override
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim) {
    bool useX = true;
    if (axisDim is GridAxisDim) {
      useX = (axisDim).isXAxis;
    }
    if (axisDim is PolarAxisDim) {
      useX = axisDim.isRadius;
    }

    // TODO: implement getAxisMaxText
    throw UnimplementedError();
  }

  @override
  dynamic getDimData(CoordType type, AxisDim dim, data) {
    var cd = data as StackItemData;
    if (type.isPolar()) {
      return (dim as PolarAxisDim).isRadius ? cd.x : cd.y;
    } else {
      return (dim as GridAxisDim).isXAxis ? cd.x : cd.y;
    }
  }
}
