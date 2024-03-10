import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ParallelAxisImpl extends LineAxisRender<ParallelAxis, ParallelAxisAttrs> {
  final Direction direction;
  bool expand = true;

  ParallelAxisImpl(super.context, super.axis, this.direction, {super.axisIndex});

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {}

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {}

  @override
  List<ElementRender>? onLayoutSplitArea(ParallelAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    return null;
  }

  @override
  List<ElementRender>? onLayoutSplitLine(ParallelAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    return null;
  }

  @override
  ParallelAxisAttrs onBuildDefaultAttrs() => ParallelAxisAttrs(
        Rect.zero,
        Offset.zero,
        Offset.zero,
        Size.zero,
        Size.zero,
        true,
      );
}

class ParallelAxisAttrs extends LineAxisAttrs {
  Size textStartSize;
  Size textEndSize;
  bool expand;

  ParallelAxisAttrs(
    super.rect,
    super.start,
    super.end,
    this.textStartSize,
    this.textEndSize,
    this.expand, {
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  @override
  ParallelAxisAttrs copy() {
    return ParallelAxisAttrs(
      rect,
      start,
      end,
      textStartSize,
      textEndSize,
      expand,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
