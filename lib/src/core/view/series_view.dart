import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///强制要求提供一个Series和Layout;并简单包装了部分手势操作
///除此之外，每个SeriesView 默认添加一个Layer
abstract class SeriesView<T extends ChartSeries, L extends LayoutHelper> extends GestureView {
  T? _series;

  T get series => _series!;

  L? _layoutHelper;

  L get layoutHelper => _layoutHelper!;

  SeriesView(super.context, T series) {
    _series = series;
    layoutParams = series.layoutParams;
  }

  @override
  void onCreate() {
    super.onCreate();
    _layoutHelper = buildLayoutHelper(_layoutHelper);
    bindSeries(series);
    layoutHelper.addListener(requestDraw);
  }

  @override
  void onDispose() {
    unBindSeries();
    layoutHelper.removeListener(requestDraw);
    _translationEvent = null;
    _scaleEvent = null;
    _layoutHelper?.dispose();
    _layoutHelper = null;
    _series?.clearListener();
    _series = null;
    super.onDispose();
  }

  L buildLayoutHelper(L? oldHelper);

  @override
  void onUpdateDataCommand(covariant Command c) {
    layoutHelper.onSeriesDataUpdate();
  }

  @override
  void onSeriesConfigChangeCommand(covariant Command c) {
    _layoutHelper = buildLayoutHelper(_layoutHelper);
    super.onSeriesConfigChangeCommand(c);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    layoutHelper.doLayout(changed, LayoutType.layout);
  }

  @override
  void onDrawBackground(CCanvas canvas) {
    Color? color = series.backgroundColor;
    if (color != null) {
      mPaint.reset();
      mPaint.color = color;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(-left, -top, width, height), mPaint);
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

  SeriesViewTranslationEvent? _translationEvent;

  void sendTranslationEvent() {
    if (!context.hasEventListener(EventType.seriesViewTranslation)) {
      return;
    }
    _translationEvent ??= SeriesViewTranslationEvent(series, id, translationX, translationY);
    _translationEvent!.translationX = translationX;
    _translationEvent!.translationY = translationY;
    context.dispatchEvent(_translationEvent!);
  }

  SeriesViewScaleEvent? _scaleEvent;

  void sendScaleEvent(double zoom, double originX, double originY) {
    if (!context.hasEventListener(EventType.seriesViewScale)) {
      return;
    }
    _scaleEvent ??= SeriesViewScaleEvent(series, id, 1, 0, 0);
    _scaleEvent!.zoom = zoom;
    _scaleEvent!.originY = originY;
    _scaleEvent!.originX = originX;
    context.dispatchEvent(_scaleEvent!);
  }
}
