import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///坐标轴发生了滚动
///一般是由于用户滚动操作触发
class AxisScrollEvent extends ChartEvent {
  final CoordLayout coord;
  final List<BaseAxisRender> axis;
  Direction? direction;
  double scrollOffset;

  AxisScrollEvent(
    this.coord,
    this.axis,
    this.scrollOffset,
    this.direction,
  );

  CoordType get coordType => coord.coordType;

  String get coordViewId => coord.id;

  String get coordId => coord.props.id;

  @override
  EventType get eventType => EventType.axisScroll;
}

class AxisChangeEvent extends ChartEvent {
  final CoordLayout coord;
  final List<BaseAxisRender> axis;
  final Direction direction;

  CoordType get coordType => coord.coordType;

  String get coordViewId => coord.id;

  String get coordId => coord.props.id;

  AxisChangeEvent(this.coord, this.axis, this.direction);

  @override
  EventType get eventType => EventType.axisChange;
}

class AxisLabelClickEvent extends ChartEvent {
  final String coordId;
  final String coordViewId;
  final CoordType coordType;
  final String axisId;
  final String axisViewId;
  final BaseScale scale;
  dynamic label;
  Offset offset;

  AxisLabelClickEvent(
    this.coordId,
    this.coordViewId,
    this.coordType,
    this.axisId,
    this.axisViewId,
    this.scale,
    this.label,
    this.offset,
  );

  @override
  EventType get eventType => EventType.axisLabelClick;
}
