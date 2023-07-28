import 'dart:ui';

import '../../component/index.dart';
import '../../model/enums/direction.dart';
import 'parallel_axis.dart';
import 'parallel_coord.dart';

class ParallelAxisImpl extends LineAxisImpl<ParallelAxis, ParallelAxisAttrs, ParallelCoord> {
  final Direction direction;

  bool expand = true;

  ParallelAxisImpl(super.context, super.coord, super.axis, this.direction, {super.axisIndex});

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Offset scroll) {}

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Offset scroll) {}
}

class ParallelAxisAttrs extends LineAxisAttrs {
  final Size textStartSize;
  final Size textEndSize;
  final bool expand;

  ParallelAxisAttrs(
    super.scaleRatio,
    super.scroll,
    super.rect,
    super.start,
    super.end, {
    this.expand = true,
    this.textStartSize = Size.zero,
    this.textEndSize = Size.zero,
    super.splitCount,
  });

  @override
  ParallelAxisAttrs copyWith(
      {double? scaleRatio,
      double? scroll,
      Rect? rect,
      Offset? start,
      Offset? end,
      Size? textStartSize,
      Size? textEndSize,
      bool? expand,
      int? splitCount}) {
    return ParallelAxisAttrs(
      scaleRatio ?? this.scaleRatio,
      scroll ?? this.scroll,
      rect ?? this.rect,
      start ?? this.start,
      end ?? this.end,
      textStartSize: textStartSize ?? this.textStartSize,
      textEndSize: textEndSize ?? this.textEndSize,
      splitCount: splitCount,
    );
  }
}
