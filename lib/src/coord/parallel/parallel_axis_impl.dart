import 'dart:ui';

import '../../component/index.dart';
import '../../core/render/ccanvas.dart';
import '../../model/enums/direction.dart';
import 'parallel_axis.dart';

class ParallelAxisImpl extends LineAxisImpl<ParallelAxis, ParallelAxisAttrs> {
  final Direction direction;
  bool expand = true;

  ParallelAxisImpl(super.context, super.axis, super.attrs, this.direction);

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {}

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {}
}

class ParallelAxisAttrs extends LineAxisAttrs {
  Size textStartSize;
  Size textEndSize;
  bool expand;

  ParallelAxisAttrs(
    super.axisIndex,
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
      axisIndex,
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
