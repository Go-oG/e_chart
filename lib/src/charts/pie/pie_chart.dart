import 'dart:math';
import 'dart:ui';

import 'package:e_chart/src/ext/offset_ext.dart';

import '../../action/hover_action.dart';
import '../../animation/animator_props.dart';
import '../../animation/chart_tween.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/view.dart';
import '../../gesture/chart_gesture.dart';
import '../../model/enums/circle_align.dart';
import '../../model/text_position.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'layout.dart';
import 'pie_series.dart';
import 'pie_tween.dart';

/// 饼图
class PieView extends ChartView {
  final PieSeries series;
  final PieLayers _layers = PieLayers();
  final List<PieNode> _nodeList = [];
  final List<ChartTween> _tweenList = [];
  final RectGesture _gesture = RectGesture();

  PieView(this.series) {
    _gesture.hoverMove = (e) {
      _handleHover(toLocalOffset(e.globalPosition));
    };
    _gesture.click = (e) {
      _handleHover(toLocalOffset(e.globalPosition));
    };
  }

  PieNode? _hoverNode;

  void _handleHover(Offset offset) {
    offset = offset.translate(-series.center[0].convert(width), -series.center[1].convert(height));
    PieNode? node = findNode(offset);
    bool hasSame = node == _hoverNode;
    if (hasSame) {
      return;
    }
    for (var ele in _tweenList) {
      ele.stop();
    }
    _tweenList.clear();
    List<ChartTween> tl = [];
    if (_hoverNode != null) {
      PieNode tmpNode = _hoverNode!;
      _hoverNode = null;
      PieTween tween = PieTween(tmpNode.end, tmpNode.start);
      tmpNode.start = tmpNode.end;
      tmpNode.end = tmpNode.start;
      tween.addListener(() {
        tmpNode.cur = tween.value;
        tmpNode.cur.select = false;
      });
      tl.add(tween);
    }
    if (node != null) {
      _hoverNode = node;
      PieProps end = node.cur.clone();
      end.or *= 1.05;
      PieTween tween = PieTween(node.cur, end);
      node.end = end;
      node.start = node.cur;
      tween.addListener(() {
        node.cur = tween.value;
        node.cur.select = true;
      });
      tl.add(tween);
    }
    ChartDoubleTween doubleTween = ChartDoubleTween(0, 1, duration: const Duration(milliseconds: 150));
    doubleTween.addListener(() {
      for (var element in tl) {
        element.update(doubleTween.value);
      }
      invalidate();
    });
    _tweenList.add(doubleTween);
    doubleTween.start(context);
  }

  PieNode? findNode(Offset offset) {
    Offset center = _computeCenterPoint();
    double maxSize = min(center.dx, center.dy);
    double minRadius = series.innerRadius.convert(maxSize);
    if (offset.distance2(Offset.zero) <= minRadius) {
      return null;
    }

    PieNode? node;
    for (var ele in _nodeList) {
      PieProps cur = ele.cur;
      if (offset.inSector(cur.ir, cur.or, cur.startAngle, cur.sweepAngle)) {
        node = ele;
        break;
      }
    }

    return node;
  }

  @override
  void onAttach() {
    super.onAttach();
    context.addGesture(_gesture);
  }
  @override
  void onDetach() {
    context.removeGesture(_gesture);
    super.onDetach();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _gesture.rect = globalAreaBound;
    Offset center = _computeCenterPoint();
    double maxSize = min(center.dx, center.dy);
    double minRadius = series.innerRadius.convert(maxSize);
    double maxRadius = series.outerRadius.convert(maxSize);
    _nodeList.clear();
    _nodeList.addAll(_layers.layout(series.data, series, minRadius, maxRadius, width, height));
    for (var element in _nodeList) {
      element.start = element.cur;
      element.end = element.cur;
    }
  }

  @override
  void onLayoutEnd() {
    _exeAnimator();
  }

  void _exeAnimator() {
    AnimatorProps? info = series.animation;
    if (info == null) {
      return;
    }
    ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
    PieAnimatorStyle style = series.animatorStyle;
    for (var ele in _nodeList) {
      ele.end = ele.cur.clone();
      ele.start = ele.cur.clone();
      PieProps start = ele.start;
      start.sweepAngle = 0;
      if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
        start.startAngle = series.offsetAngle;
      } else {
        start.startAngle = ele.cur.startAngle;
      }
      if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
        ele.start.or = ele.start.ir;
      }
    }
    PieTween pieTween = PieTween(PieProps(), PieProps());
    tween.addListener(() {
      double v = tween.value;
      for (int i = 0; i < _nodeList.length; i++) {
        PieNode nowNode = _nodeList[i];
        pieTween.changeValue(nowNode.start, nowNode.end);
        nowNode.cur = pieTween.safeGetValue(v);
      }
      invalidate();
    });
    tween.start(context);
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    Offset center = _computeCenterPoint();
    canvas.translate(center.dx, center.dy);
    var action = HoverAction();
    for (var element in _nodeList) {
      AreaStyle? style = series.areaStyleFun.call(element.data, element.cur.select ? action : null);
      if (style == null) {
        continue;
      }
      Path path = element.toPath();
      style.drawPath(canvas, mPaint, path);
    }
    for (var ele in _nodeList) {
      drawText(canvas, ele);
    }
    canvas.restore();
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
      Offset tmpOffset = circlePoint(node.cur.or, node.cur.startAngle + (node.cur.sweepAngle / 2));
      Offset tmpOffset2 = circlePoint( node.cur.or + style.guideLine.length, node.cur.startAngle + (node.cur.sweepAngle / 2));
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
