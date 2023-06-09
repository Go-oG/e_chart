import 'package:flutter/material.dart';
import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/view.dart';
import '../../model/text_position.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'funnel_series.dart';
import 'layout.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries> {
  final List<FunnelNode> _nodeList = [];

  FunnelView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onCreate() {
    super.onCreate();
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
  }

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

  @override
  void onHoverEnd() {
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
  }

  void _handleHover(Offset local) {
    Rect rect = series.computePositionBySelf(left, top, right, bottom);
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
    super.onLayout(left, top, right, bottom);
    Rect rect = series.computePositionBySelf(left, top, right, bottom);
    _nodeList.clear();
    FunnelLayers layers = FunnelLayers(series.gap, series.direction, series.sort, series.align);
    _nodeList.addAll(layers.layout(rect.width, rect.height, series.dataList, maxValue: series.maxValue));
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

  void _drawText(Canvas canvas, FunnelNode node) {
    if (node.data.label == null || node.data.label!.isEmpty || series.labelStyleFun == null) {
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
    style.draw(canvas, mPaint, node.data.label!, position);
  }
}
