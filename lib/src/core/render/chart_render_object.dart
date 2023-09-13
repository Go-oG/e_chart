import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

import 'base_render.dart';

class ChartRenderObject extends RenderBox {
  Size? defaultSize;
  BoxConstraints? oldConstraints;
  Size oldSize = Size.zero;
  BaseRender? _render;

  BaseRender get render => _render!;

  set render(BaseRender? r) {
    if (_render == r) {
      markNeedsPaint();
      return;
    }
    var old = _render;
    _render = r;
    r?.onStart();
    onMeasure();
    onLayout();
    didUpdateRender(r, old);
  }

  ChartRenderObject(BaseRender render, this.defaultSize) {
    _render = render;
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _render?.clearListener();
    _render?.addListener(() {
      var c = render.value;
      if (c.code == Command.invalidate.code) {
        markNeedsCompositingBitsUpdate();
        markNeedsPaint();
      } else if (c.code == Command.reLayout.code) {
        markNeedsCompositingBitsUpdate();
        markNeedsLayout();
      }
    });
    _render?.onStart();
    _render?.context.gestureDispatcher.enable();
  }

  @override
  void detach() {
    _render?.context.gestureDispatcher.disable();
    _render?.clearListener();
    _render?.onStop();
    super.detach();
  }

  @override
  void dispose() {
    _render?.dispose();
    super.dispose();
  }

  @override
  void performResize() {
    if (oldConstraints != null && constraints == oldConstraints && oldSize != Size.zero) {
      size = oldSize;
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
    onMeasure();
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
    _render?.onMeasure(w, h);
  }

  void onLayout() {
    _render?.onLayout(size.width, size.height);
  }

  @override
  void performLayout() {
    super.performLayout();
    onLayout();
    markNeedsSemanticsUpdate();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    CCanvas cc = CCanvas(context);
    _render?.draw(cc, size);
    context.setIsComplexHint();
    context.setWillChangeHint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  void didUpdateRender(BaseRender? newRender, BaseRender? oldRender) {
    if (!attached) {
      return;
    }
    oldRender?.clearListener();
    newRender?.clearListener();
    newRender?.addListener(() {
      var c = newRender.value;
      if (c.code == Command.invalidate.code) {
        markNeedsPaint();
      } else if (c.code == Command.reLayout.code) {
        markNeedsLayout();
      }
    });
    newRender?.context.gestureDispatcher.enable();
    markNeedsSemanticsUpdate();
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    _render?.context.gestureDispatcher.handleEvent(event, entry);
  }
}
