import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/tick_result.dart';
import 'package:flutter/material.dart';

abstract class BaseTick {
  bool show;

  ///坐标轴刻度是否朝内
  bool inside;

  /// 刻度长度
  num length;

  ///刻度样式
  LineStyle lineStyle;

  ///刻度文字样式
  LabelStyle labelStyle;

  ///文字和刻度之间的间距
  num labelPadding;

  ///Tick 和轴线之间的偏移
  num tickOffset;

  ///坐标轴刻度的显示间隔，只在类目轴中有效
  ///-1为默认
  /// 0 强制显示所有标签
  /// 1 『隔一个标签显示一个标签』
  /// 2 隔两个标签显示一个标签，以此类推
  int interval;

  BaseTick({
    this.show = true,
    this.inside = true,
    this.length = 8,
    this.lineStyle = const LineStyle(),
    this.labelStyle = const LabelStyle(),
    this.labelPadding = 3,
    this.interval = -1,
    this.tickOffset = 0,
  });

  List<TickResult> computeLineTick(final Offset start, final Offset end, List<DynamicText> ticks) {
    int tickCount = ticks.length;
    tickCount = max(tickCount, 2);
    double distance = end.distance2(start);
    double interval = distance / (tickCount - 1);
    int dir = inside ? -1 : 1;
    double len = length.toDouble();
    double clampAngle = end.offsetAngle(start);
    List<TickResult> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      Offset s = start.translate(i * interval, 0);
      Offset e = s.translate(0, dir * len);
      Offset ts = s.rotateOffset(clampAngle, center: start);

      Offset te = e.rotateOffset(clampAngle, center: start);

      if (i >= ticks.length) {
        resultList.add(TickResult(ts, te, null, null));
        continue;
      }

      Offset end = e.translate(0, dir * labelPadding.toDouble());
      if (ticks.length == 1) {
        end = end.translate(interval * 0.5, 0);
      }
      end = end.rotateOffset(clampAngle, center: start);
      TextDrawConfig config = TextDrawConfig(end, align: toAlignment(clampAngle + 90, inside));
      resultList.add(TickResult(ts, te, config, ticks[i]));
    }
    return resultList;
  }

  List<TickResult> computeCircleTick(double radius, num startAngle, num sweepAngle, List<DynamicText> ticks,
      {Offset center = Offset.zero}) {
    int tickCount = ticks.length;
    tickCount = max(tickCount, 2);
    double interval = sweepAngle / (tickCount - 1);
    double r = radius;
    r += tickOffset;
    final int dir = inside ? -1 : 1;
    final double gap1 = length.toDouble() * dir;
    final double gap2 = length + labelPadding.toDouble() * dir;

    List<TickResult> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      double sa = startAngle + i * interval;
      Offset tickStart = circlePoint(r, sa, center);
      Offset tickEnd = circlePoint(r + gap1, sa, center);
      if (i >= ticks.length) {
        resultList.add(TickResult(tickStart, tickEnd, null, null));
        continue;
      }

      if (ticks.length == 1) {
        sa += interval * 0.5;
      }

      Offset o3 = circlePoint(r + gap2, sa, center);
      TextDrawConfig config = TextDrawConfig(o3, align: toAlignment(sa, inside));
      resultList.add(TickResult(tickStart, tickEnd, config, ticks[i]));
    }
    return resultList;
  }
}
