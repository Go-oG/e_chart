import 'package:flutter/material.dart';

import '../../../coord/index.dart';
import '../../../ext/offset_ext.dart';
import '../../../model/dynamic_data.dart';
import '../../../model/enums/align2.dart';
import '../../../model/text_position.dart';
import '../../../style/line_style.dart';
import '../../../utils/align_util.dart';
import '../../scale/scale_base.dart';
import '../../scale/scale_linear.dart';
import '../../tick/main_tick.dart';
import 'base_axis_impl.dart';

///圆形轴
class ArcAxisImpl extends BaseAxisImpl<AngleAxis, ArcProps> {
  ArcAxisImpl(super.axis, [int index = 0]) : super(index: index);

  @override
  BaseScale buildScale(ArcProps props, List<DynamicData> dataSet) {
    if (props.clockwise) {
      return axis.toScale(props.angleOffset, props.angleOffset + props.sweepAngle, dataSet);
    }
    return axis.toScale(props.angleOffset + props.sweepAngle, props.angleOffset, dataSet);
  }

  @override
  TextDrawConfig layoutAxisName() {
    Offset start = props.center;
    Offset end = circlePoint(props.radius, props.angleOffset, props.center);
    if (axis.nameAlign == Align2.center || titleNode.label.isEmpty) {
      return TextDrawConfig(Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2), align: Alignment.center);
    }
    if (axis.nameAlign == Align2.start) {
      return TextDrawConfig(start, align: Alignment.centerLeft);
    }
    return TextDrawConfig(end, align: toAlignment(end.offsetAngle(start)));
  }

  @override
  void drawAxisLine(Canvas canvas, Paint paint) {
    if (!axis.axisLine.show) {
      return;
    }
    num allAngle = axis.sweepAngle.abs();
    num angleInterval = allAngle / scale.tickCount;
    num angle = 0;
    while (angle < axis.sweepAngle) {
      num startAngle = axis.offsetAngle + angle;
      num sa = axis.clockwise ? angleInterval : -angleInterval;
      angle += angleInterval;
      dynamic firstData = scale.domainValue(startAngle);
      dynamic endData = scale.domainValue(startAngle + sa);

      LineStyle? style;
      if (axis.axisLine.styleFun != null) {
        style = axis.axisLine.styleFun!.call(DynamicData(firstData), DynamicData(endData), null);
      }
      style ??= axis.axisLine.style;
      style.drawArc(canvas, paint, props.radius, startAngle, sa);
    }
  }

  @override
  void drawAxisTick(Canvas canvas, Paint paint) {
    List<String> ticks = obtainTicks();
    if (ticks.isEmpty) {
      return;
    }
    if (ticks.length == 1) {
      dynamic firstData = scale.domainValue(axis.offsetAngle);
      dynamic endData = scale.domainValue(axis.offsetAngle + axis.sweepAngle);
      MainTick? tick;
      if (axis.axisLine.tickFun != null) {
        tick = axis.axisLine.tickFun!.call(DynamicData(firstData), DynamicData(endData), null);
      }
      tick ??= axis.axisLine.tick;
      tick?.drawCircleTick(canvas, paint, props.radius, axis.offsetAngle, axis.sweepAngle, ticks);
      return;
    }

    num allAngle = axis.sweepAngle.abs();
    num angleInterval = allAngle / (ticks.length - 1);
    for (int i = 0; i < ticks.length - 1; i++) {
      num startAngle = axis.offsetAngle + angleInterval * i;
      dynamic firstData = scale.domainValue(startAngle);
      dynamic endData = scale.domainValue(startAngle + angleInterval);
      MainTick? tick;
      if (axis.axisLine.tickFun != null) {
        tick = axis.axisLine.tickFun!.call(DynamicData(firstData), DynamicData(endData), null);
      }
      tick ??= axis.axisLine.tick;
      List<String> tl = [];
      tl.add(ticks[i]);
      if (i < ticks.length - 2) {
        tl.add('');
      } else {
        tl.add(ticks[i + 1]);
      }
      tick?.drawCircleTick(canvas, paint, props.radius, startAngle, angleInterval, tl, category: axis.category);
    }

    if (axis.subAxisStyle != null) {
      int length = ticks.length;
      num interval = axis.sweepAngle.abs() / length;
      if (!axis.clockwise) {
        interval *= -1;
      }

      int count = length;
      if (axis.sweepAngle % 360 != 0 && axis.sweepAngle > 0) {
        count += 1;
      }

      for (int i = 0; i < count; i++) {
        num angle = axis.offsetAngle + i * interval;
        Offset offset = circlePoint(props.radius, angle);
        axis.subAxisStyle!.drawPolygon(canvas, paint, [Offset.zero, offset]);
      }
    }
  }

  @override
  List<String> obtainTicks() {
    if (scale is! LinearScale) {
      return super.obtainTicks();
    }
    return axis.buildTicks(scale);
  }

  num dataToAngle(DynamicData data) {
    return scale.rangeValue(data);
  }
}

///在半径轴中使用
class ArcProps {
  final Offset center;
  final double radius;
  final double angleOffset;
  final double sweepAngle;
  final bool clockwise;

  ArcProps(
    this.center,
    this.angleOffset,
    this.radius, {
    this.sweepAngle = 360,
    this.clockwise = true,
  });
}
