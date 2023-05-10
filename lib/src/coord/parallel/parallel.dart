import 'dart:ui';

import '../../model/enums/direction.dart';
import '../../model/string_number.dart';
import '../coord_layout.dart';
import '../rect_coord.dart';
import 'parallel_axis.dart';
import 'parallel_layout.dart';

class Parallel extends RectCoordinate {
  final Direction direction;
  final bool expandable;
  final int expandStartIndex;
  final int expandCount;
  final num expandWidth;
  final Color? backgroundColor;
  final List<ParallelAxis> axisList;
  final SNumber leftPadding;
  final SNumber topPadding;
  final SNumber rightPadding;
  final SNumber bottomPadding;

  Parallel({
    this.direction = Direction.horizontal,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.width,
    super.height,
    this.expandable = false,
    this.expandStartIndex=0,
    this.expandCount = 0,
    this.expandWidth = 30,
    this.axisList = const [],
    this.backgroundColor,
    this.leftPadding=const SNumber.percent(5),
    this.topPadding=const SNumber.percent(5),
    this.rightPadding=const SNumber.percent(5),
    this.bottomPadding=const SNumber.percent(2),
    super.id,
    super.show,
  });

  @override
  CoordinateLayout toLayout() {
    return ParallelLayout(this);
  }
}
