import 'package:flutter/material.dart';

import '../../../core/chart_notifier.dart';
import '../../../core/command.dart';
import '../../../model/dynamic_data.dart';
import '../../../model/dynamic_text.dart';
import '../../../model/text_position.dart';
import '../../scale/scale_base.dart';
import '../base_axis.dart';

abstract class BaseAxisImpl<T extends BaseAxis, L> extends ChartNotifier<Command> {
  final int index;
  final T axis;
  late final AxisTitleNode titleNode;

  //布局参数
  late L props;
  late BaseScale scale;

  bool expanded = true;
  bool show = true;

  BaseAxisImpl(this.axis, {this.index = 0}) : super(Command.none) {
    show = axis.show;
    titleNode = AxisTitleNode(axis.name);
  }

  void measure(double parentWidth, double parentHeight) {}

  void layout(L layoutProps, List<DynamicData> dataSet) {
    this.props = layoutProps;
    scale = buildScale(layoutProps, dataSet);
    titleNode.config = layoutAxisName();
  }

  BaseScale buildScale(L props, List<DynamicData> dataSet);

  TextDrawConfig layoutAxisName();

  void draw(Canvas canvas, Paint paint) {
    if (!axis.show) {
      return;
    }
    onDrawAxisLine(canvas, paint);
    onDrawAxisTick(canvas, paint);
    onDrawAxisName(canvas, paint);
  }

  void onDrawAxisName(Canvas canvas, Paint paint) {
    if (titleNode.label == null || titleNode.label!.isEmpty) {
      return;
    }
    axis.nameStyle.draw(canvas, paint, titleNode.label!, titleNode.config);
  }

  void onDrawAxisLine(Canvas canvas, Paint paint) {}

  void onDrawAxisTick(Canvas canvas, Paint paint) {}

  List<DynamicText> obtainTicks() {
    return axis.buildTicks(scale);
  }

  ///返回当前轴显示的可见范围
  ///返回值为 scale 中的range
  List<num> get viewRange {
    return [scale.range[0], scale.range[1]];
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }
}

class AxisTitleNode {
  final DynamicText? label;
  TextDrawConfig config = TextDrawConfig(Offset.zero, align: Alignment.center);

  AxisTitleNode(this.label);
}

///存放轴的布局信息
class AxisTickInfo {}
