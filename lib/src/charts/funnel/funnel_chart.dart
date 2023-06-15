import 'package:flutter/material.dart';
import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/view.dart';
import '../../model/dynamic_text.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import 'funnel_series.dart';
import 'layout.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries> {
  final FunnelLayout _layout = FunnelLayout();
  FunnelView(super.series);

  double alpha = 0;

  @override
  bool get enableDrag => false;

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
    List<FunnelNode> nodeList = _layout.nodeList;
    for (var node in nodeList) {
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
    List<FunnelNode> nodeList = _layout.nodeList;
    for(var node in nodeList){
      bool old=node.hovering;
      node.hovering=node.select=node.path.contains(local);
      if(old==node.hovering&&old){return;}
    }
    invalidate();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.dataList, width, height);
    doAnimator();
  }

  void doAnimator() {
    AnimatorProps? info = series.animation;
    if (info == null) {
      alpha = 0;
      return;
    }
    ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
    tween.addListener(() {
      alpha = 1 - tween.value;
      invalidate();
    });
    tween.start(context);
  }

  @override
  void onDraw(Canvas canvas) {
    List<FunnelNode> nodeList = _layout.nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    for (var node in nodeList) {
      series.areaStyleFun.call(node).drawPath(canvas, mPaint, node.path);
    }
    for (var node in nodeList) {
      _drawText(canvas, node);
    }
    if (alpha != 0) {
      Paint paint = Paint();
      paint.color = Colors.white.withOpacity(alpha);
      paint.style = PaintingStyle.fill;
      canvas.drawRect(areaBounds, paint);
    }
  }

  void _drawText(Canvas canvas, FunnelNode node) {
    TextDrawConfig? config = node.textConfig;
    DynamicText? label = node.data.label;
    if (label == null || label.isEmpty || config == null) {
      return;
    }

    LabelStyle? style =series.labelStyleFun?.call(node);
    if (style == null || !style.show) {
      return;
    }
    List<Offset>? ol = node.labelLine;
    if (ol != null) {
      style.guideLine.style.drawPolygon(canvas, mPaint, ol);
    }
    style.draw(canvas, mPaint, label, config);
  }
}
