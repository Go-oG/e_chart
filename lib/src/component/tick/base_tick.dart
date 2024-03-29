import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/axis/model/tick_result.dart';
import 'package:flutter/material.dart';

abstract class BaseTick {
  bool show;

  ///坐标轴刻度是否朝内
  bool inside;

  ///坐标轴刻度的显示间隔，只在类目轴中有效
  /// <=0时显示所有Tick
  /// 1 『隔一个Tick显示一个Tick』
  /// 2 隔两个Tick显示一个Tick，以此类推
  int interval;

  /// 刻度长度
  num length;

  ///刻度样式
  LineStyle lineStyle;

  BaseTick({
    this.show = true,
    this.inside = false,
    this.length = 8,
    this.lineStyle = const LineStyle(),
    this.interval = -1,
  });

}
