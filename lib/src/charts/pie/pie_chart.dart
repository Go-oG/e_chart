import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/src/ext/offset_ext.dart';

import '../../action/hover_action.dart';
import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/command.dart';
import '../../core/view.dart';
import '../../model/enums/circle_align.dart';
import '../../model/text_position.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'layout.dart';
import 'pie_series.dart';
import 'pie_tween.dart';

/// 饼图
class PieView extends SeriesView<PieSeries> {
  final PieLayout pieLayer = PieLayout();

  PieView(super.series);

  @override
  bool get enableDrag => false;

  PieNode? _hoverNode;

  @override
  void onClick(Offset offset) {
    _handleHover(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _handleHover(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _handleHover(offset);
  }

  void _handleHover(Offset offset) {
    Offset center = pieLayer.center;
    offset = offset.translate(-center.dx, -center.dy);
    pieLayer.handleHover(offset);
  }

  @override
  void onUpdateDataCommand(Command c) {
    super.onUpdateDataCommand(c);
    pieLayer.doLayout(context, series, series.data, width, height);
    if(c.runAnimation){
      doAnimator();
    }else{
      invalidate();
    }
  }

  @override
  void onStart() {
    super.onStart();
    pieLayer.addListener(invalidate);
  }

  @override
  void onStop() {
    pieLayer.removeListener(invalidate);
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    pieLayer.doLayout(context, series, series.data, width, height);
    doAnimator();
  }

  void doAnimator() {
    List<PieNode> nodeList = pieLayer.nodeList;
    AnimatorProps? info = series.animation;
    if (info == null || nodeList.isEmpty) {
      return;
    }

    PieAnimatorStyle style = series.animatorStyle;
    Map<PieNode, PieProps> startMap = {};
    Map<PieNode, PieProps> endMap = {};
    for (var ele in nodeList) {
      endMap[ele] = ele.props;
      PieProps start = ele.props.clone(sweepAngle: 0);
      if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
        start = start.clone(startAngle: series.offsetAngle);
      }
      if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
        start = start.clone(or: start.ir);
      }
      startMap[ele] = start;
    }
    PieNode first = nodeList.first;

    ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
    PieTween pieTween = PieTween(first.props, first.props);
    tween.addListener(() {
      double v = tween.value;
      each(nodeList, (node, i) {
        pieTween.changeValue(startMap[node]!, endMap[node]!);
        node.props = pieTween.safeGetValue(v);
      });
      invalidate();
    });
    tween.start(context);
  }

  @override
  void onDestroy() {
    pieLayer.dispose();
    super.onDestroy();
  }

  @override
  void onDraw(Canvas canvas) {
    var action = HoverAction();
    List<PieNode> nodeList = pieLayer.nodeList;
    for (var node in nodeList) {
      AreaStyle? style = series.areaStyleFun.call(node.data, node.select ? action : null);
      if (style == null) {
        continue;
      }
      Path path = node.toPath();
      style.drawPath(canvas, mPaint, path);
    }
    for (var node in nodeList) {
      drawText(canvas, node);
    }
  }

  void drawText(Canvas canvas, PieNode node) {
    if (node.data.label == null || node.data.label!.isEmpty) {
      return;
    }
    if (series.labelAlign == CircleAlign.center) {
      if (_hoverNode == null) {
        return;
      }
      if (_hoverNode != node) {
        return;
      }
      TextDrawConfig? position = node.computeTextPosition(series);
      if (position == null) {
        return;
      }
      LabelStyle? style = series.labelStyleFun?.call(node.data, null);
      if (style == null || !style.show) {
        return;
      }
      style.draw(canvas, mPaint, node.data.label!, position);
      return;
    }

    TextDrawConfig? position = node.computeTextPosition(series);
    if (position == null) {
      return;
    }

    LabelStyle? style = series.labelStyleFun?.call(node.data, null);
    if (style == null || !style.show) {
      return;
    }
    style.draw(canvas, mPaint, node.data.label!, position);
    if (series.labelAlign == CircleAlign.outside) {
      Offset tmpOffset = circlePoint(node.props.or, node.props.startAngle + (node.props.sweepAngle / 2));
      Offset tmpOffset2 = circlePoint(node.props.or + style.guideLine.length, node.props.startAngle + (node.props.sweepAngle / 2));
      Path path = Path();
      path.moveTo(tmpOffset.dx, tmpOffset.dy);
      path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
      path.lineTo(position.offset.dx, position.offset.dy);
      style.guideLine.style.drawPath(canvas, mPaint, path);
    }
  }

  Offset _computeCenterPoint() {
    double x = series.center[0].convert(width);
    double y = series.center[1].convert(height);
    return Offset(x, y);
  }
}
