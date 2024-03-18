import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/model/models.dart';

abstract class StackView<T extends StackItemData, G extends StackGroupData<T, G>, S extends StackSeries<T, G>,
    L extends StackHelper<T, G, S>> extends CoordChildView<S, L> {
  StackView(super.context, super.series);

  bool get useSingleLayer {
    if (series.realtimeSort || series.dynamicRange || series.dynamicLabel) {
      return false;
    }
    return true;
  }

  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    layoutHelper.doMeasure(parentWidth, parentHeight);
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
