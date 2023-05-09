
import 'package:flutter/material.dart';
import 'package:xchart/src/ext/offset_ext.dart';
import '../../../model/dynamic_data.dart';
import '../../../model/enums/align2.dart';
import '../../../model/text_position.dart';
import '../../../style/line_style.dart';
import '../../../utils/align_util.dart';
import '../../scale/scale_base.dart';
import '../../tick/main_tick.dart';
import '../base_axis.dart';
import 'base_axis_impl.dart';

class LineAxisImpl<T extends BaseAxis> extends BaseAxisImpl<T, LineProps> {
  LineAxisImpl(super.axis, {int index = 0}) : super(index: index);

  @override
  BaseScale buildScale(LineProps props, List<DynamicData> dataSet) {
    num distance = props.start.distance2(props.end);
    distance *= scaleValue;
    return axis.toScale(0, distance, dataSet);
  }

  @override
  TextDrawConfig layoutAxisName() {
    Offset center;
    Offset p;

    if (axis.nameAlign == Align2.end) {
      center = props.start;
      p = props.end;
    } else if (axis.nameAlign == Align2.start) {
      center = props.end;
      p = props.start;
    } else {
      center = props.start;
      p = Offset((props.start.dx + props.end.dx) / 2, (props.start.dy + props.end.dy) / 2);
    }
    num a = p.offsetAngle(center);
    double r = center.distance2(p);
    r += axis.nameGap;
    return TextDrawConfig(circlePoint(r, a,center), align: toAlignment(a));
  }

  @override
  void drawAxisLine(Canvas canvas, Paint paint) {
    List<num> viewPortList = viewRange; //distance
    num first = viewPortList[0];
    num end = viewPortList[1];
    num allDistance = (scale.range[0] - scale.range[1]).abs();
    num viewInterval = scale.viewInterval;
    while (first < end) {
      num pre = first;
      num next = first + viewInterval;
      first = next;
      Offset startOffset, endOffset;
      double percent = pre / allDistance;
      startOffset = Offset(
        props.start.dx + (props.end.dx - props.start.dx) * percent,
        props.start.dy + (props.end.dy - props.start.dy) * percent,
      );
      startOffset = startOffset.translate(-scrollValue, -scrollValue);
      percent = (next) / allDistance;
      endOffset = Offset(
        props.start.dx + (props.end.dx - props.start.dx) * percent,
        props.start.dy + (props.end.dy - props.start.dy) * percent,
      );
      endOffset = endOffset.translate(-scrollValue, -scrollValue);

      dynamic firstData = scale.domainValue(pre);
      dynamic endData = scale.domainValue(next);

      LineStyle? style;
      if (axis.axisLine.styleFun != null) {
        style = axis.axisLine.styleFun!.call(DynamicData(firstData), DynamicData(endData), null);
      }
      style ??= axis.axisLine.style;
      style.drawPolygon(canvas, paint, [startOffset, endOffset]);
    }
  }

  @override
  void drawAxisTick(Canvas canvas, Paint paint) {
    if (axis.axisLine.tick == null) {
      return;
    }
    List<String> ticks = obtainTicks();
    if (ticks.isEmpty) {
      return;
    }
    if (ticks.length == 1) {
      return;
    }

    List<num> viewPortList = viewRange; //distance
    num first = viewPortList[0];
    num end = viewPortList[1];
    num allDistance = (scale.range[0] - scale.range[1]).abs();
    num viewInterval = allDistance / ticks.length;
    if (!axis.category) {
      viewInterval = allDistance / (ticks.length - 1);
    }
    int count = (end - first) ~/ viewInterval;

    for (int i = 0; i < count; i += 1) {
      num pre = first + i * viewInterval;
      num next = first + (i + 1) * viewInterval;
      int firstIndex = pre ~/ viewInterval;
      int nextIndex = next ~/ viewInterval;
      Offset startOffset, endOffset;
      double percent = pre / allDistance;
      startOffset = Offset(
        props.start.dx + (props.end.dx - props.start.dx) * percent,
        props.start.dy + (props.end.dy - props.start.dy) * percent,
      );
      startOffset = startOffset.translate(-scrollValue, -scrollValue);
      percent = next / allDistance;
      endOffset = Offset(
        props.start.dx + (props.end.dx - props.start.dx) * percent,
        props.start.dy + (props.end.dy - props.start.dy) * percent,
      );

      endOffset = endOffset.translate(-scrollValue, -scrollValue);
      MainTick? tick;
      if (axis.axisLine.tickFun != null) {
        dynamic firstData = scale.domainValue(pre);
        dynamic endData = scale.domainValue(next);
        tick = axis.axisLine.tickFun!.call(DynamicData(firstData), DynamicData(endData), null);
      }
      tick ??= axis.axisLine.tick;
      List<String> subList = [];
      if (axis.category) {
        subList.add(ticks[firstIndex]);
      } else {
        subList.add(ticks[firstIndex]);
        subList.add(ticks[nextIndex]);
      }
      tick?.drawLineTick(canvas, paint, startOffset, endOffset, subList);
    }
  }
}

///直线轴使用
class LineProps {
  //轴线的起始和结束位置
  final Rect rect;
  final Offset start;
  final Offset end;

  ///存储文字的最大宽度和高度
  final Size textStartSize;
  final Size textEndSize;

  LineProps(
    this.rect,
    this.start,
    this.end, {
    this.textStartSize = Size.zero,
    this.textEndSize = Size.zero,
  });

  double get distance => start.distance2(end);
}
