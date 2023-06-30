import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisImpl extends BaseAxisImpl<AngleAxis, ArcProps> {
  static const int maxAngle = 360;

  AngleAxisImpl(super.axis, [int index = 0]) : super(index: index);

  @override
  BaseScale buildScale(ArcProps props, List<DynamicData> dataSet) {
    num s = props.angleOffset;
    if (!props.clockwise) {
      s += maxAngle;
    }
    num e = props.angleOffset;
    if (props.clockwise) {
      e += maxAngle;
    }
    return axis.toScale(s, e, dataSet);
  }

  @override
  TextDrawConfig layoutAxisName() {
    DynamicText? label = titleNode.label;
    Offset start = props.center;
    Offset end = circlePoint(props.radius, props.angleOffset, props.center);
    if (axis.nameAlign == Align2.center || (label == null || label.isEmpty)) {
      return TextDrawConfig(Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2), align: Alignment.center);
    }
    if (axis.nameAlign == Align2.start) {
      return TextDrawConfig(start, align: Alignment.centerLeft);
    }
    return TextDrawConfig(end, align: toAlignment(end.offsetAngle(start)));
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (axisLine == null || !axisLine.show) {
      return;
    }
    int count = scale.tickCount - 1;
    int direction = axis.clockwise ? 1 : -1;
    num angleInterval = direction * maxAngle / count;

    for (int i = 0; i < count; i++) {
      num startAngle = axis.offsetAngle + i * angleInterval;
      num sa = angleInterval;
      dynamic firstData = scale.domainValue(startAngle);
      dynamic endData = scale.domainValue(startAngle + sa);
      LineStyle? style;
      if (axisLine.styleFun != null) {
        style = axisLine.styleFun!.call(DynamicData(firstData), DynamicData(endData));
      }
      style ??= axisLine.style;
      style.drawArc(canvas, paint, props.radius, startAngle, sa, props.center);
    }
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (axisLine == null) {
      return;
    }
    List<DynamicText> ticks = obtainTicks();
    if (ticks.isEmpty) {
      return;
    }
    if (ticks.length == 1) {
      dynamic firstData = scale.domainValue(axis.offsetAngle);
      dynamic endData = scale.domainValue(axis.offsetAngle + maxAngle);
      MainTick? tick;
      if (axisLine.tickFun != null) {
        tick = axisLine.tickFun!.call(DynamicData(firstData), DynamicData(endData));
      }
      tick ??= axisLine.tick;
      tick?.drawCircleTick(canvas, paint, props.radius, axis.offsetAngle, maxAngle, ticks, center: props.center);
      return;
    }

    int direction = props.clockwise ? 1 : -1;
    int count = ticks.length;
    if (!axis.category) {
      count -= 1;
    }

    final num angleInterval = direction * maxAngle / count;
    for (int i = 0; i < count; i++) {
      num startAngle = props.angleOffset + angleInterval * i;
      dynamic firstData = scale.domainValue(startAngle);
      dynamic endData = scale.domainValue(startAngle + angleInterval);
      MainTick? tick;
      if (axisLine.tickFun != null) {
        tick = axisLine.tickFun!.call(DynamicData(firstData), DynamicData(endData));
      }
      tick ??= axisLine.tick;

      List<DynamicText> tl = [ticks[i]];

      ///这里添加一个empty是为了计算方便
      if (!axis.category) {
        tl.add(DynamicText.empty);
      }

      tick?.drawCircleTick(
        canvas,
        paint,
        props.radius,
        startAngle,
        angleInterval,
        tl,
        category: axis.category,
        center: props.center,
      );
    }

    if (axis.subAxisStyle != null) {
      for (int i = 0; i < count; i++) {
        num angle = axis.offsetAngle + i * angleInterval;
        Offset offset = circlePoint(props.radius, angle, props.center);
        axis.subAxisStyle!.drawPolygon(canvas, paint, [props.center, offset]);
      }
    }
  }

  @override
  List<DynamicText> obtainTicks() {
    if (scale is! LinearScale) {
      return super.obtainTicks();
    }
    return axis.buildTicks(scale);
  }

  ///将一个"Y轴数据" 转换到角度范围
  ///如果轴类型为category 则返回角度的范围，否则返回单一角度
  List<num> dataToAngle(DynamicData data) {
    if(!axis.category){
      return [scale.rangeValue(data)];
    }
    return scale.rangeValue2(data);
  }
}

///在半径轴中使用
class ArcProps {
  final Offset center;
  final double radius;
  final double angleOffset;
  final bool clockwise;

  ArcProps(
    this.center,
    this.angleOffset,
    this.radius, {
    this.clockwise = true,
  });
}
