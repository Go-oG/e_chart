import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

///强制要求提供一个Series和Layout;并简单包装了部分手势操作
///除此之外，每个SeriesView 默认添加一个Layer
abstract class SeriesView<T extends ChartSeries, L extends LayoutHelper> extends GestureView {
  final T series;
  L? _layoutHelper;

  L get layoutHelper => _layoutHelper!;

  SeriesView(this.series) {
    if (series is RectSeries) {
      layoutParams = (series as RectSeries).toLayoutParams();
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    _layoutHelper = buildLayoutHelper(_layoutHelper);
  }

  @override
  void onDestroy() {
    _layoutHelper?.dispose();
    series.dispose();
    super.onDestroy();
  }

  L buildLayoutHelper(L? oldHelper);

  @override
  void onUpdateDataCommand(covariant Command c) {
    layoutHelper.doLayout(selfBoxBound, globalBound, LayoutType.update);
    super.onUpdateDataCommand(c);
  }

  @override
  void onSeriesConfigChangeCommand(covariant Command c) {
    _layoutHelper = buildLayoutHelper(_layoutHelper);
    super.onSeriesConfigChangeCommand(c);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    layoutHelper.doLayout(selfBoxBound, globalBound, LayoutType.layout);
  }

  @override
  void onDrawBackground(CCanvas canvas) {
    Color? color = series.backgroundColor;
    if (color != null) {
      mPaint.reset();
      mPaint.color = color;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(selfBoxBound, mPaint);
    }
  }

  @override
  void onClick(Offset offset) {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onClick(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onHoverStart(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onHoverMove(offset);
  }

  @override
  void onHoverEnd() {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onHoverEnd();
  }

  @override
  void onDragStart(Offset offset) {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onDragStart(offset);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onDragMove(offset, diff);
  }

  @override
  void onDragEnd() {
    if (layoutHelper.inAnimation && !layoutHelper.allowGestureInAnimation) {
      return;
    }
    layoutHelper.onDragEnd();
  }

  @mustCallSuper
  @override
  void onStart() {
    super.onStart();
    bindSeries(series);
    layoutHelper.addListener(invalidate);
  }

  @mustCallSuper
  @override
  void onStop() {
    unBindSeries();
    layoutHelper.removeListener(invalidate);
    super.onStop();
  }

  @override
  void onCoordScaleUpdate(CoordScale scale) {
    layoutHelper.onCoordScaleUpdate(scale);
  }

  @override
  void onCoordScaleStart(CoordScale scale) {
    layoutHelper.onCoordScaleStart(scale);
  }

  @override
  void onCoordScaleEnd(CoordScale scale) {
    layoutHelper.onCoordScaleEnd(scale);
  }

  @override
  void onCoordScrollStart(CoordScroll scroll) {
    layoutHelper.onCoordScrollUpdate(scroll);
  }

  @override
  void onCoordScrollUpdate(CoordScroll scroll) {
    layoutHelper.onCoordScrollUpdate(scroll);
  }

  @override
  void onCoordScrollEnd(CoordScroll scroll) {
    layoutHelper.onCoordScrollEnd(scroll);
  }

  @override
  void onLayoutByParent(LayoutType type) {
    layoutHelper.onLayoutByParent(type);
  }

  @override
  bool get useSingleLayer => series.useSingleLayer;

}
