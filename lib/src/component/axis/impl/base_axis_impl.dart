import 'package:flutter/material.dart';

import '../../../model/dynamic_data.dart';
import '../../../model/text_position.dart';
import '../../scale/scale_base.dart';
import '../base_axis.dart';

abstract class BaseAxisImpl<T extends BaseAxis, L> {
  final int index;
  final T axis;
  late final AxisTitleNode titleNode;

  //布局参数
  late L props;
  late BaseScale scale;

  bool expanded = true;
  bool show = true;

  num _scroll = 0;
  num _scale = 1;

  BaseAxisImpl(this.axis, {this.index = 0}) {
    show = axis.show;
    titleNode = AxisTitleNode(axis.name);
  }

  void measure(double parentWidth, double parentHeight) {}

  void layout(L layoutProps, List<DynamicData> dataSet) {
    this.props = layoutProps;
    scale = buildScale(layoutProps, dataSet);
    titleNode.config= layoutAxisName();
  }

  BaseScale buildScale(L props, List<DynamicData> dataSet);

  TextDrawConfig layoutAxisName();

  void draw(Canvas canvas, Paint paint) {
    if (!axis.show) {
      return;
    }
    drawAxisLine(canvas, paint);
    drawAxisTick(canvas, paint);
    drawAxisName(canvas, paint);
  }

  void drawAxisName(Canvas canvas, Paint paint) {
    if (titleNode.label.isNotEmpty) {
      axis.nameStyle.draw(canvas, paint, titleNode.label, titleNode.config);
    }
  }

  void drawAxisLine(Canvas canvas, Paint paint) {}

  void drawAxisTick(Canvas canvas, Paint paint) {}

  List<String> obtainTicks() {
    return axis.buildTicks(scale);
  }

  ///返回当前轴显示的可见范围
  ///返回值为 scale 中的range
  List<num> get viewRange {
    return [scale.range[0], scale.range[1]];
  }

  void scrollDiff(num s) {
    setScroll(_scroll + s);
  }

  void setScroll(num scroll) {
    _scroll = scroll;
  }

  void scaleDiff(num s) {
    setScale(_scale + s);
  }

  void setScale(num scale) {
    _scale = scale;
  }

  double get scrollValue => _scroll.toDouble();

  double get scaleValue => _scale.toDouble();
}

class AxisTitleNode {
  final String label;
  TextDrawConfig config=TextDrawConfig(Offset.zero,align: Alignment.center);
  AxisTitleNode(this.label);
}

///存放轴的布局信息
class AxisTickInfo {}
