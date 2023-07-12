import 'dart:math' as m;
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/tick_result.dart';
import 'package:flutter/material.dart';

class LineAxisImpl<T extends BaseAxis, P extends LineProps> extends BaseAxisImpl<T, P> {
  LineAxisImpl(super.axis, {super.axisIndex = 0});

  List<LineRange> lineTickList = [];

  double _scaleFactor = 1;

  double get scaleFactor => _scaleFactor;

  double _scrollOffset = 0;

  double get scrollOffset => _scrollOffset;

  void updateScaleFactor(num v) {
    if (v <= 0) {
      throw ChartError('scaleFactor 必须大于0 当前值：$v');
    }
    if (_scaleFactor == v) {
      return;
    }
    _scaleFactor = v.toDouble();
    onScaleFactorChange(_scaleFactor);
  }

  void updateScrollOffset(num v) {
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
    AxisStyle axisLine = axis.axisStyle;
    each(lineTickList, (tick, i) {
      AreaStyle? style = axisLine.getSplitAreaStyle(i, lineTickList.length, theme);
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
    bool vertical = start.dx == end.dx;
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    each(lineTickList, (tick, i) {
      LineStyle? style = axisLine.getSplitLineStyle(i, lineTickList.length, theme);
      if (style == null) {
        return;
      }
      List<Offset> ol = [];
      if (vertical) {
        if (start.dx <= end.dx) {
          ol.add(tick.start);
          ol.add(tick.start.translate(coord.width, 0));
        } else {
          ol.add(tick.end);
          ol.add(tick.end.translate(-coord.width, 0));
        }
      } else {
        if (start.dy < end.dy) {
          ol.add(tick.start);
          ol.add(tick.start.translate(0, coord.height));
        } else {
          ol.add(tick.end);
          ol.add(tick.end.translate(0, -coord.height));
        }
      }
      style.drawPolygon(canvas, paint, ol);
    });
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisLine = axis.axisStyle;
    AxisTheme theme = getAxisTheme();
    each(lineTickList, (tick, p1) {
      LineStyle? style = axisLine.getAxisLineStyle(p1, lineTickList.length, theme);
      style?.drawPolygon(canvas, paint, [tick.start, tick.end]);
    });
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisStyle = axis.axisStyle;
    var theme = getAxisTheme();
    int maxCount = lineTickList.length;
    each(lineTickList, (line, p1) {
      MainTick? tick = axisStyle.getMainTick(p1, maxCount, theme);
      var minorTick = axisStyle.getMinorTick(p1, maxCount, theme);
      bool b1 = (tick != null && tick.show);
      bool b2 = (minorTick != null && minorTick.show);
      if (b1 || b2) {
        each(line.tick, (at, p2) {
          if (b1) {
            tick?.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
          }
          if (b2) {
            each(at.minorTickList, (minor, p1) {
              minorTick?.lineStyle.drawPolygon(canvas, paint, [minor.start, minor.end]);
            });
          }
        });
      }

      ///绘制标签
      var label = axisStyle.getLabelStyle(p1, maxCount, theme);
      var minorLabel = axisStyle.getMinorLabelStyle(p1, maxCount, theme);

      b1 = (label != null && label.show);
      b2 = (minorLabel != null && minorLabel.show);

      if (b1 || b2) {
        each(line.tick, (at, p2) {
          if (b1 && at.text != null && at.textConfig != null) {
            label?.draw(canvas, paint, at.text!, at.textConfig!);
          }
          if (b2) {
            each(at.minorTickList, (minor, p1) {
              if (minor.text != null && minor.textConfig != null) {
                minorLabel?.draw(canvas, paint, minor.text!, minor.textConfig!);
              }
            });
          }
        });
      }
    });

  }

  @override
  void updateTickPosition() {
    final num distance = scale.range[1] - scale.range[0];

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

    var theme = getAxisTheme();
    for (int i = 0; i < ol.length - 1; i++) {
      var s = ol[i];
      var e = ol[i + 1];
      num pre = s.distance2(props.start);
      num next = e.distance2(props.start);
      dynamic firstData = scale.toData(pre);
      dynamic endData = scale.toData(next);

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

      ///计算Tick和label的标签
      List<TickResult> result = _computeTickAndLabel(i, ol.length - 1, theme, s, e, textList);
      rangeList.add(LineRange(s, e, firstData, endData, result));
    }
    this.lineTickList = List.from(rangeList, growable: false);
  }

  final MainTick _tmpTick = MainTick();
  final MinorTick _tmpMinorTick = MinorTick();

  List<TickResult> _computeTickAndLabel(
    final int index,
    final int maxIndex,
    final AxisTheme theme,
    final Offset start,
    final Offset end,
    final List<DynamicText> ticks,
  ) {
    final AxisStyle style = axis.axisStyle;
    final MainTick tick = style.getMainTick(index, maxIndex, theme) ?? _tmpTick;
    int tickCount = ticks.length;
    tickCount = max([tickCount, 2]).toInt();
    final double distance = end.distance2(start);
    final double interval = distance / (tickCount - 1);
    final int dir = tick.inside ? -1 : 1;
    final double len = tick.length.toDouble();
    final double clampAngle = end.offsetAngle(start);

    List<TickResult> resultList = [];

    for (int i = 0; i < tickCount; i++) {
      final Offset s = start.translate(i * interval, 0);
      final Offset e = s.translate(0, dir * len);

      ///Tick的位置
      final Offset ts = s.rotateOffset(clampAngle, center: start);
      final Offset te = e.rotateOffset(clampAngle, center: start);

      TickResult tickResult;

      ///计算MainLabel位置
      if (i >= ticks.length) {
        tickResult = TickResult(ts, te, null, null);
      } else {
        int dir2 = style.axisLabel.inside ? -1 : 1;
        Offset end = e.translate(0, dir2 * (style.axisLabel.margin + style.axisLabel.padding) * 1);
        if (ticks.length == 1) {
          end = end.translate(interval * 0.5, 0);
        }
        end = end.rotateOffset(clampAngle, center: start);
        TextDrawConfig config = TextDrawConfig(end, align: toAlignment(clampAngle + 90, style.axisLabel.inside));
        tickResult = TickResult(ts, te, config, ticks[i]);
      }

      ///计算minorTick 和minorLabel
      tickResult.minorTickList.addAll(_computeMinorTickAndLabel(
        index,
        maxIndex,
        s,
        e,
        clampAngle,
        tick.inside,
        start,
      ));
      resultList.add(tickResult);
    }
    return resultList;
  }

  List<TickResult> _computeMinorTickAndLabel(
    final int index,
    final int maxIndex,
    final Offset s,
    final Offset e,
    final double clampAngle,
    final bool inside,
    final Offset center,
  ) {
    final AxisStyle style = axis.axisStyle;
    final MinorTick tick = style.getMinorTick(index, maxIndex, getAxisTheme()) ?? _tmpMinorTick;
    int tickCount = tick.splitNumber;
    if (tickCount <= 0) {
      return [];
    }
    final bool labelInside = style.axisLabel.inside;

    final double distance = e.distance2(s);
    final double interval = distance / (tickCount - 1);
    final int tickDir = inside ? -1 : 1;
    final int labelDir = labelInside ? -1 : 1;
    final double tickLen = tick.length.toDouble();

    List<TickResult> resultList = [];
    for (int i = 1; i < tickCount; i++) {
      final Offset s2 = s.translate(i * interval, 0);
      final Offset e2 = s2.translate(0, tickDir * tickLen);

      ///Tick的位置
      final Offset ts = s2.rotateOffset(clampAngle, center: center);
      final Offset te = e2.rotateOffset(clampAngle, center: center);

      num offsetY = style.axisLabel.margin + style.axisLabel.padding;
      if (inside == labelInside) {
        offsetY += tickLen;
      }
      Offset end = s.translate(0, labelDir * offsetY * 1);
      end = end.rotateOffset(clampAngle, center: center);

      TextDrawConfig config = TextDrawConfig(end, align: toAlignment(clampAngle + 90, style.axisLabel.inside));
      dynamic data = scale.toData(s.distance2(center) + i * interval);
      DynamicText? text = style.axisLabel.formatter?.call(data);
      TickResult tickResult = TickResult(ts, te, config, text);
      resultList.add(tickResult);
    }
    return resultList;
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
