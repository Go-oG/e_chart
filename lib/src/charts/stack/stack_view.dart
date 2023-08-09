import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class StackView<T extends StackItemData, G extends StackGroupData<T>, S extends StackSeries<T, G>, L extends StackHelper<T, G, S>>
    extends CoordChildView<S, L> {
  StackView(super.series);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    layoutHelper.doMeasure(series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    onDrawGroupBk(canvas);
    onDrawBar(canvas);
    onDrawBarLabel(canvas);
    onDrawMark(canvas);
  }

  void onDrawGroupBk(Canvas canvas) {}

  void onDrawBar(Canvas canvas) {}

  void onDrawBarLabel(Canvas canvas) {}

  /// 绘制标记线和点
  void onDrawMark(Canvas canvas) {
    var markLineFun = series.markLineFun;
    var markPointFun = series.markPointFun;
    var markPoint = series.markPoint;
    var markLine = series.markLine;
    if (markLineFun == null && markPointFun == null && markPoint == null && markLine == null) {
      return;
    }
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (markLineFun != null || markLine != null) {
      each(layoutHelper.markLineList, (ml, i) {
        ml.line.draw(canvas, mPaint, ml.start.offset, ml.end.offset);
      });
    }
    each(layoutHelper.markPointList, (mp, i) {
      mp.markPoint.draw(canvas, mPaint, mp.offset);
    });
    canvas.restore();
  }

  @override
  int allocateDataIndex(int index) {
    each(series.data, (p0, p1) {
      p0.styleIndex = p1 + index;
    });
    return series.data.length;
  }

}
