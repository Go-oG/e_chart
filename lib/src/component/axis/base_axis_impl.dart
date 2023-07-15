import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/axis/axis_attrs.dart';
import 'package:e_chart/src/component/axis/model/axis_layout_result.dart';
import 'package:flutter/material.dart';

import 'model/axis_tile_node.dart';

abstract class BaseAxisImpl<T extends BaseAxis, L extends AxisAttrs, R extends AxisLayoutResult> extends ChartNotifier<Command> {
  final int axisIndex;
  final Context context;
  final T axis;
  late final AxisTitleNode titleNode;
  late L attrs;
  late BaseScale scale;
  late R layoutResult;

  bool expanded = true;

  BaseAxisImpl(this.context, this.axis, {this.axisIndex = 0}) : super(Command.none) {
    titleNode = AxisTitleNode(axis.name);
  }

  void doMeasure(double parentWidth, double parentHeight) {}

  void doLayout(L attrs, List<DynamicData> dataSet) {
    this.attrs = attrs;
    scale = onBuildScale(attrs, dataSet);
    titleNode.config = onLayoutAxisName();
    layoutResult = onLayout(attrs, scale, dataSet);
  }

  R onLayout(L attrs, BaseScale scale, List<DynamicData> dataSet);

  BaseScale onBuildScale(L attrs, List<DynamicData> dataSet);

  TextDrawConfig onLayoutAxisName();

  void draw(Canvas canvas, Paint paint, Rect coord) {
    var axisLine = axis.axisStyle;
    if (!axisLine.show) {
      return;
    }
    onDrawAxisSplitArea(canvas, paint, coord);
    onDrawAxisSplitLine(canvas, paint, coord);
    onDrawAxisTick(canvas, paint);
    onDrawAxisLine(canvas, paint);
    onDrawAxisName(canvas, paint);
  }

  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {}

  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {}

  void onDrawAxisName(Canvas canvas, Paint paint) {
    if (titleNode.label == null || titleNode.label!.isEmpty) {
      return;
    }
    axis.nameStyle.draw(canvas, paint, titleNode.label!, titleNode.config);
  }

  void onDrawAxisLine(Canvas canvas, Paint paint) {}

  void onDrawAxisTick(Canvas canvas, Paint paint) {}

  List<DynamicText> obtainLabel() {
    return axis.buildLabels(scale);
  }

  AxisTheme getAxisTheme() {
    if (axis.isCategoryAxis) {
      return context.config.theme.categoryAxisTheme;
    }
    if (axis.isTimeAxis) {
      return context.config.theme.timeAxisTheme;
    }
    if (axis.isLogAxis) {
      return context.config.theme.logAxisTheme;
    }
    return context.config.theme.valueAxisTheme;
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }
}
