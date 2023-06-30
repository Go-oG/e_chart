import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:e_chart/src/ext/offset_ext.dart';

import '../../model/dynamic_text.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../../utils/align_util.dart';

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

  Alignment get mode {
    Alignment of = Alignment.bottomCenter;
    if (!inside) {
      of = Alignment.topCenter;
    }
    return of;
  }

  ///绘制直线上的Tick(直线可能是斜线)
  ///如果ticks 只有一个则居中
  ///大于等于2则在首尾均匀分布
  void drawLineTick(Canvas canvas, Paint paint, Offset start, Offset end, List<DynamicText> ticks) {
    if (ticks.isEmpty || !show) {
      logPrint('baseTick drawLineTick() 数据为空');
      return;
    }
    num b2 = length * length;
    num b4 = (length + labelPadding) * (length + labelPadding);
    int maxLimit = ticks.length;
    int tickCount = ticks.length;
    if (ticks.length == 1) {
      maxLimit += 1;
    } else {
      tickCount -= 1;
    }

    double tickXInterval = (end.dx - start.dx) / tickCount;
    double tickYInterval = (end.dy - start.dy) / tickCount;

    for (int i = 0; i < maxLimit; i++) {

      Offset sOffset = Offset(start.dx + i * tickXInterval, start.dy + i * tickYInterval);
      Offset eOffset = Offset(start.dx + (i + 1) * tickXInterval, start.dy + (i + 1) * tickYInterval);

      //计算结尾点和起始点轴线夹角
      double clampAngle = eOffset.offsetAngle(start);
      double distance = sOffset.distance2(start);
      double c2 = distance * distance + b2;
      double c = sqrt(c2);

      //夹角
      double angle = atan(length / distance) * 180 / pi;
      double resultAngle = inside ? (clampAngle - angle) : (clampAngle + angle);
      if (resultAngle < 0) {
        resultAngle += 360;
      }

      //Tick End position
      Offset o3 = circlePoint(c, resultAngle, start);
      lineStyle.drawPolygon(canvas, paint, [sOffset, o3]);
      logPrint('baseTick drawLineTick() $sOffset  $o3');
      if (i >= ticks.length) {
        continue;
      }

      ///计算文本绘制点
      if (ticks.length == 1) {
        distance = Offset(start.dx + (i + 0.5) * tickXInterval, start.dy + (i + 0.5) * tickYInterval).distance2(start);
        eOffset = Offset(start.dx + (i + 1.5) * tickXInterval, start.dy + (i + 1.5) * tickYInterval);
        clampAngle = eOffset.offsetAngle(Offset(start.dx, 0));
      }

      c2 = distance * distance + b4;
      c = sqrt(c2);
      angle = atan((length + labelPadding) / distance) * 180 / pi;
      resultAngle = inside ? (clampAngle - angle) : (clampAngle + angle);
      if (resultAngle < 0) {
        resultAngle += 360;
      }
      Offset textOffset = circlePoint(c, resultAngle, start);
      TextDrawConfig config = TextDrawConfig(textOffset, align: toAlignment(clampAngle + 90, inside));
      labelStyle.draw(canvas, paint, ticks[i], config);
    }
  }

  void drawCircleTick(
    Canvas canvas,
    Paint paint,
    double radius,
    num startAngle,
    num sweepAngle,
    List<DynamicText> ticks, {
    Offset center = Offset.zero,
    bool category = false,
  }) {
    if (ticks.isEmpty || !show) {
      return;
    }
    int count = ticks.length;
    if (!category) {
      count -= 1;
    }
    double angleInterval = sweepAngle / count;
    double r = radius;
    r += tickOffset;
    double gap1 = length.toDouble();
    double gap2 = length + labelPadding.toDouble();
    if (inside) {
      gap1 *= -1;
      gap2 *= -1;
    }

    for (int i = 0; i < ticks.length; i++) {
      double sa = startAngle + i * angleInterval;
      Offset o1 = circlePoint(r, sa, center);
      Offset o2 = circlePoint(r + gap1, sa, center);
      lineStyle.drawPolygon(canvas, paint, [o1, o2]);
      if (ticks[i].isEmpty) {
        continue;
      }
      Offset o3 = circlePoint(r + gap2, sa, center);
      TextDrawConfig config = TextDrawConfig(o3, align: toAlignment(sa, inside));
      labelStyle.draw(canvas, paint, ticks[i], config);
    }
  }
}
