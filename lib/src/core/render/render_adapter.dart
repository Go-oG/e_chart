import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'chart_render.dart';
import 'default_render.dart';

///该类负责将Flutter原生的布局、渲染流程映射到我们的ChartRender中
class RenderAdapter extends RenderBox {
  Size? defaultSize;
  BoxConstraints? oldConstraints;
  Size oldSize = Size.zero;
  ChartRender? _render;
  TickerProvider? _provider;

  RenderAdapter(ChartOption option, Size? size, this._provider) {
    _initRender(option, _provider!, size);
  }

  void onUpdateRender(ChartOption option, Size? size, TickerProvider provider) {
    Logger.i('onUpdateRender');
    _provider=provider;
    _disPoseRender(_render);
    _render = null;

    ///直接重建
    _initRender(option, provider, size);
    _clearOldLayoutSize();
    _render?.onStart();
    markNeedsLayout();
    markNeedsCompositingBitsUpdate();
    markNeedsSemanticsUpdate();
  }

  void onUnmountRender() {
    _disPoseRender(_render);
  }

  void _disPoseRender(ChartRender? render) {
    if (render == null) {
      return;
    }
    render.clearListener();
    render.onStop();
    try {
      render.dispose();
    } catch (e) {
      Logger.e(e);
    }
  }

  void _initRender(ChartOption option, TickerProvider provider, Size? size) {
    defaultSize = size;
    oldSize=Size.zero;

    var ra = PlatformDispatcher.instance.views.first.devicePixelRatio;
    var render = DefaultRender(option, provider, ra);
    render.addListener(() {
      var c = render.value;
      if (c.code == Command.invalidate.code) {
        markNeedsCompositingBitsUpdate();
        markNeedsPaint();
      } else if (c.code == Command.reLayout.code) {
        markNeedsCompositingBitsUpdate();
        markNeedsLayout();
      }
    });
    option.calendarList;
    option.addListener(() {
      var c = option.value;
      if (c == Command.configChange) {
        onUpdateRender(option, defaultSize, provider);
      }
    });
    render.onCreate();
    _render = render;
  }

  void _clearOldLayoutSize(){
    oldConstraints=null;
    oldSize=Size.zero;
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _render?.onStart();
  }

  @override
  void detach() {
    _render?.onStop();
    super.detach();
  }

  @override
  void dispose() {
    _render?.dispose();
    _render = null;
    _provider=null;
    super.dispose();
  }

  @override
  void performResize() {
    if (oldConstraints != null && constraints == oldConstraints && oldSize != Size.zero) {
      size = oldSize;
      Logger.i('performResize() 前后约束不变 不进行测量');
      return;
    }
    oldConstraints = constraints;
    double minW = constraints.minWidth;
    double minH = constraints.minHeight;
    double maxW = constraints.maxWidth;
    double maxH = constraints.maxHeight;
    double w = adjustSize(maxW, minW, defaultSize?.width);
    double h = adjustSize(maxH, minH, defaultSize?.height);
    size = Size(w, h);
    oldSize = size;
  }

  double adjustSize(double maxSize, double minSize, double? defaultSize) {
    if (maxSize.isFinite && maxSize > 0) {
      return maxSize;
    }
    if (minSize.isFinite && minSize > 0) {
      return minSize;
    }

    if (defaultSize != null && defaultSize > 0) {
      return defaultSize;
    }

    throw ChartError("size constraints is NaN Or Infinite and defaultSize is Null");
  }

  void onMeasure() {
    double w = size.width;
    double h = size.height;
    _render?.measure(w, h);
  }

  void onLayout() {
    _render?.layout(0, 0, size.width, size.height);
  }

  @override
  void performLayout() {
    super.performLayout();
    onMeasure();
    onLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _render?.draw(CCanvas(context));
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    _render?.context.gestureDispatcher.handleEvent(event, entry);
  }
}
