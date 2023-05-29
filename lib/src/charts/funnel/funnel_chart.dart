import 'package:flutter/material.dart';
import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/view.dart';
import '../../gesture/chart_gesture.dart';
import '../../gesture/gesture_event.dart';
import '../../model/text_position.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'funnel_series.dart';
import 'layout.dart';

/// 漏斗图
class FunnelView extends  ChartView {
  final FunnelSeries series;
  final List<FunnelNode> _nodeList = [];

  FunnelView(this.series);

  final RectGesture rectGesture = RectGesture();

  @override
  void onAttach() {
    super.onAttach();
    AnimatorProps? info = series.animation;
    if (info != null) {
      ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
      tween.addListener(() {
        for (var element in _nodeList) {
          element.animatorPercent = tween.value;
        }
        invalidate();
      });
      tween.start(context);
    }
    rectGesture.hoverStart = _handleHover;
    rectGesture.hoverMove = _handleHover;
    rectGesture.click = _handleHover;
    rectGesture.hoverEnd = (e) {
      for (var node in _nodeList) {
        if (node.textScaleFactor != 1) {
          ChartDoubleTween tween =
              ChartDoubleTween(node.textScaleFactor, 1, duration: const Duration(milliseconds: 150), curve: Curves.fastLinearToSlowEaseIn);
          tween.addListener(() {
            node.textScaleFactor = tween.value;
            invalidate();
          });
          tween.start(context);
          break;
        }
      }
    };
    context.gestureDispatcher.addGesture(rectGesture);
  }

  void _handleHover(NormalEvent e) {
    Rect rect = series.computePositionBySelf(left, top, right, bottom);
    Offset local = toLocalOffset(e.globalPosition);
    local = local.translate(-rect.left, -rect.top);
    for (var node in _nodeList) {
      Path p = node.path;
      double start = 1;
      double end = 1;
      if (p.contains(local)) {
        start = 1;
        end = 1.25;
      } else {
        if (node.textScaleFactor != 1) {
          start = node.textScaleFactor;
          end = 1;
        }
      }

      if (start != end) {
        ChartDoubleTween tween =
            ChartDoubleTween(start, end, duration: const Duration(milliseconds: 150), curve: Curves.fastLinearToSlowEaseIn);
        tween.addListener(() {
          node.textScaleFactor = tween.value;
          invalidate();
        });
        tween.start(context);
      }
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    Rect rect = series.computePositionBySelf(left, top, right, bottom);
    _nodeList.clear();
    FunnelLayers layers = FunnelLayers(series.gap, series.direction, series.sort, series.align);
    _nodeList.addAll(layers.layout(rect.width, rect.height, series.dataList, maxValue: series.maxValue));
    rectGesture.rect = globalAreaBound;
  }

  @override
  void onDraw(Canvas canvas) {
    if (series.dataList.isEmpty) {
      return;
    }
    Rect rect = series.computePositionBySelf(left, top, right, bottom);
    canvas.save();
    canvas.translate(rect.left - left, rect.top - top);
    for (var element in _nodeList) {
      AreaStyle? style = series.areaStyleFun.call(element.data, null);
      style?.drawPolygonArea(canvas, mPaint, element.pointList);
    }
    for (var element in _nodeList) {
      _drawText(canvas, element);
    }
    canvas.restore();
  }

  @override
  void onDetach() {
    rectGesture.clear();
    context.gestureDispatcher.addGesture(rectGesture);
    super.onDetach();
  }

  void _drawText(Canvas canvas, FunnelNode node) {
    if (node.data.labelText == null || node.data.labelText!.isEmpty || series.labelStyleFun == null) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node.data, null);
    if (style == null || !style.show) {
      return;
    }
    TextDrawConfig? position = node.computeTextPosition(series);
    if (position == null) {
      return;
    }
    List<Offset>? ol = node.computeLabelLineOffset(series);
    if (ol != null) {
      style.guideLine.style.drawPolygon(canvas, mPaint, ol);
    }
    style.draw(
      canvas,
      mPaint,
      node.data.labelText!,
      position
    );
  }
}
