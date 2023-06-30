import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LineAxisImpl<T extends BaseAxis, P extends LineProps> extends BaseAxisImpl<T, P> {
  LineAxisImpl(super.axis, {int index = 0}) : super(index: index);

  double _scaleFactor = 1;

  double get scaleFactor => _scaleFactor;

  double _scrollOffset = 0;

  double get scrollOffset => _scrollOffset;

  set scaleFactor(num v) {
    if (v <= 0) {
      throw ChartError('scaleFactor 必须大于0 当前值：$v');
    }
    if (_scaleFactor == v) {
      return;
    }
    _scaleFactor = v.toDouble();
    onScaleFactorChange(_scaleFactor);
  }

  set scrollOffset(num v) {
    if (_scrollOffset == v) {
      return;
    }
    _scrollOffset = v.toDouble();
    onScrollOffsetChange(_scrollOffset);
  }

  void onScaleFactorChange(double factor) {}

  void onScrollOffsetChange(double offset) {}

  @override
  BaseScale buildScale(P props, List<DynamicData> dataSet) {
    num distance = props.start.distance2(props.end);
    distance *= scaleFactor;
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
    return TextDrawConfig(circlePoint(r, a, center), align: toAlignment(a));
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    List<num> viewPortList = viewRange; //distance
    final num first = viewPortList[0];
    final num end = viewPortList[1];

    num allDistance = scale.range[1] - scale.range[0];
    num viewInterval = scale.viewInterval.abs();
    int count = (end - first).abs() ~/ viewInterval;
    for (int i = 0; i < count; i++) {
      num pre = first + i * viewInterval;
      num next = first + (i + 1) * viewInterval;
      Offset startOffset, endOffset;
      double percent = pre / allDistance;
      startOffset = Offset(
        props.start.dx + (props.end.dx - props.start.dx) * percent,
        props.start.dy + (props.end.dy - props.start.dy) * percent,
      );
      startOffset = startOffset.translate(-scrollOffset, -scrollOffset);
      percent = next / allDistance;
      endOffset = Offset(
        props.start.dx + (props.end.dx - props.start.dx) * percent,
        props.start.dy + (props.end.dy - props.start.dy) * percent,
      );
      endOffset = endOffset.translate(-scrollOffset, -scrollOffset);
      dynamic firstData = scale.domainValue(pre);
      dynamic endData = scale.domainValue(next);
      LineStyle? style;
      if (axisLine.styleFun != null) {
        style = axisLine.styleFun!.call(DynamicData(firstData), DynamicData(endData));
      }
      style ??= axisLine.style;
      style.drawPolygon(canvas, paint, [startOffset, endOffset]);
    }
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (!axisLine.show || !axisLine.tick.show) {
      logPrint("$runtimeType 轴线不显示");
      return;
    }
    List<DynamicText> ticks = obtainTicks();
    if (ticks.isEmpty) {
      return;
    }
    if (ticks.length == 1) {
      //TODO 待完成
      logPrint("Tick Length 为 1");
      return;
    }

    //TODO 修复
    List<num> viewPortList = viewRange;
    final num first = viewPortList[0];
    final num end = viewPortList[1];

    num allDistance = (scale.range[1] - scale.range[0]).abs();
    num viewInterval = allDistance / ticks.length;
    if (!axis.category) {
      viewInterval = allDistance / (ticks.length - 1);
    }

    int count = (end - first).abs() ~/ viewInterval.abs();
    double diffX = props.end.dx - props.start.dx;
    double diffY = props.end.dy - props.start.dy;

    for (int i = 0; i < count; i += 1) {
      num pre = first + i * viewInterval;
      num next = first + (i + 1) * viewInterval;
      int firstIndex = pre ~/ viewInterval;
      int nextIndex = next ~/ viewInterval;

      Offset startOffset, endOffset;
      double percent = pre / allDistance;

      startOffset = Offset(
        props.start.dx - scrollOffset + diffX * percent,
        props.start.dy - scrollOffset + diffY * percent,
      );
      percent = next / allDistance;
      endOffset = Offset(
        props.start.dx - scrollOffset + diffX * percent,
        props.start.dy - scrollOffset + diffY * percent,
      );
      MainTick? tick;
      if (axisLine.tickFun != null) {
        dynamic firstData = scale.domainValue(pre);
        dynamic endData = scale.domainValue(next);
        tick = axisLine.tickFun!.call(DynamicData(firstData), DynamicData(endData));
      }
      tick ??= axisLine.tick;
      List<DynamicText> subList = [];
      if (axis.category) {
        subList.add(ticks[firstIndex]);
      } else {
        subList.add(ticks[firstIndex]);
        subList.add(ticks[nextIndex]);
      }

      logPrint("LineDraw $runtimeType");
      tick.drawLineTick(canvas, paint, startOffset, endOffset, subList);
    }
  }
}

///直线轴使用
class LineProps {
  final Rect rect;

  //轴线的起始和结束位置
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
