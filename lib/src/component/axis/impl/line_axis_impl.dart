import 'dart:math' as m;
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/tick_result.dart';
import 'package:flutter/material.dart';

class LineAxisImpl<T extends BaseAxis, P extends LineProps> extends BaseAxisImpl<T, P> {
  LineAxisImpl(super.axis, {int index = 0}) : super(index: index);
  List<LineRange> tickPositionList = [];

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

  @override
  void layout(P layoutProps, List<DynamicData> dataSet) {
    super.layout(layoutProps, dataSet);
    updateTickPosition();
  }

  @override
  BaseScale buildScale(P props, List<DynamicData> dataSet) {
    num distance = props.start.distance2(props.end);
    distance *= scaleFactor;
    return axis.toScale([0, distance], dataSet, false);
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
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {
    Offset start = props.start;
    Offset end = props.end;

    ///只实现垂直和水平方向
    if (!(start.dx == end.dx || start.dy == end.dy)) {
      return;
    }
    bool vertical = start.dy == end.dy;
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisLine;
    each(tickPositionList, (tick, i) {
      AreaStyle? style = axisLine.getSplitAreaStyle(i, tickPositionList.length, theme);
      if (style == null) {
        return;
      }
      Rect rect;
      if (vertical) {
        rect = Rect.fromLTRB(tick.start.dx, coord.top, tick.end.dx, coord.bottom);
      } else {
        if (start.dy <= end.dy) {
          rect = Rect.fromLTWH(tick.start.dx, tick.start.dy, coord.width, tick.start.distance2(tick.end));
        } else {
          rect = Rect.fromLTWH(tick.end.dx, tick.end.dy, coord.width, tick.start.distance2(tick.end));
        }
      }
      style.drawRect(canvas, paint, rect);
    });
  }

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {
    Offset start = props.start;
    Offset end = props.end;

    ///只实现垂直和水平方向
    if (!(start.dx == end.dx || start.dy == end.dy)) {
      return;
    }
    bool vertical = start.dy == end.dy;
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisLine;
    each(tickPositionList, (tick, i) {
      LineStyle? style = axisLine.getSplitLineStyle(i, tickPositionList.length, theme);
      if (style == null) {
        return;
      }
      List<Offset> ol = [tick.end];
      if (vertical) {
        if (start.dy < end.dy) {
          ol.add(tick.end.translate(0, coord.height));
        } else {
          ol.add(tick.end.translate(0, -coord.height));
        }
      } else {
        if (start.dx <= end.dx) {
          ol.add(tick.end.translate(coord.width, 0));
        } else {
          ol.add(tick.end.translate(-coord.width, 0));
        }
      }
      style.drawPolygon(canvas, paint, ol);
    });
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }
    AxisTheme theme = getAxisTheme();
    each(tickPositionList, (tick, p1) {
      LineStyle? style = axisLine.getAxisLineStyle(p1, tickPositionList.length, theme);
      style?.drawPolygon(canvas, paint, [tick.start, tick.end]);
    });
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }

    var theme = getAxisTheme();
    each(tickPositionList, (tp, p1) {
      var mainTick = axisLine.getMainTick(p1, tickPositionList.length, theme);
      if (mainTick == null || !mainTick.show) {
        return;
      }
      each(tp.tick, (tick, p1) {
        mainTick.lineStyle.drawPolygon(canvas, paint, [tick.start, tick.end]);
        if (tick.text != null && tick.textConfig != null) {
          mainTick.labelStyle.draw(canvas, paint, tick.text!, tick.textConfig!);
        }
      });
    });
  }

  @override
  void updateTickPosition() {
    final num firstRange = scale.range[0];
    final num endRange = scale.range[1];
    final num distance = endRange - firstRange;
    final double diffX = props.end.dx - props.start.dx;
    final double diffY = props.end.dy - props.start.dy;
    final num k = m.atan(diffX / diffY);
    final num ck = m.cos(k);
    final num sk = m.sin(k);
    final int tickCount = scale.tickCount - 1;

    List<Offset> ol = [];
    for (int i = 0; i <= tickCount; i++) {
      double percent = i / tickCount;
      double dis = distance * percent;
      Offset offset = Offset(
        props.start.dx + dis * sk,
        props.start.dy + dis * ck,
      );
      ol.add(offset);
    }

    List<LineRange> rangeList = [];
    List<DynamicText> ticks = obtainTicks();

    var tmpTick = MainTick();
    var axisLine = axis.axisLine;
    var theme = getAxisTheme();
    for (int i = 0; i < ol.length - 1; i++) {
      var s = ol[i];
      var e = ol[i + 1];
      num pre = s.distance2(props.start);
      num next = e.distance2(props.start);
      dynamic firstData = scale.toData(pre);
      dynamic endData = scale.toData(next);

      MainTick tick = axisLine.getMainTick(i, ol.length - 1, theme) ?? tmpTick;
      List<DynamicText> textList = [];
      if (i < ticks.length) {
        textList.add(ticks[i]);
      }
      if (!axis.category) {
        if (i + 1 < ticks.length) {
          textList.add(ticks[i + 1]);
        } else {
          textList.add(DynamicText.empty);
        }
      }

      ///TODO 还需要处理MinorTick
      List<TickResult> result = tick.computeLineTick(s, e, textList);
      rangeList.add(LineRange(s, e, firstData, endData, result));
    }
    this.tickPositionList = List.from(rangeList, growable: false);
  }

  void onScaleFactorChange(double factor) {}

  void onScrollOffsetChange(double offset) {}
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

class LineRange {
  final Offset start;
  final Offset end;
  final dynamic startData;
  final dynamic endData;
  final List<TickResult> tick;

  LineRange(this.start, this.end, this.startData, this.endData, this.tick);
}
