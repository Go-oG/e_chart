import 'package:flutter/material.dart';
import '../../animation/chart_tween.dart';
import '../../animation/tween/area_style_tween.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/view.dart';
import '../../core/view_state.dart';
import '../../model/dynamic_text.dart';
import '../../model/text_position.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'funnel_node.dart';
import 'funnel_series.dart';
import 'layout.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries> {
  final FunnelLayout _layout = FunnelLayout();

  FunnelView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onClick(Offset offset) {
    handleHoverEnter(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    handleHoverEnter(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    handleHoverEnter(offset);
  }

  @override
  void onHoverEnd() {
    handleCancel();
  }

  FunnelNode? oldNode;

  void handleHoverEnter(Offset local) {
    List<FunnelNode> nodeList = _layout.nodeList;
    bool result = false;
    Map<FunnelNode, AreaStyle> oldMap = {};
    Map<FunnelNode, LabelStyle> oldMap2 = {};
    FunnelNode? hoverNode;
    for (var node in nodeList) {
      oldMap[node] = node.areaStyle;
      if (node.labelStyle != null) {
        oldMap2[node] = node.labelStyle!;
      }
      if (node.path.contains(local)) {
        hoverNode = node;
        if (node.addState(ViewState.hover)) {
          result = true;
        }
      } else {
        if (node.removeState(ViewState.hover)) {
          result = true;
        }
      }
    }
    if (!result) {
      return;
    }

    final old = oldNode;
    oldNode = hoverNode;
    List<ChartTween> tl = [];
    if (old != null && oldMap.containsKey(old)) {
      AreaStyle style = series.areaStyleFun.call(old).convert(old.status);
      AreaStyleTween tween = AreaStyleTween(oldMap[old]!, style, props: series.animatorProps);
      tween.addListener(() {
        old.areaStyle = tween.value;
        invalidate();
      });
      tl.add(tween);
      ChartDoubleTween tween2 = ChartDoubleTween.fromValue(
        (old.textConfig?.scaleFactor ?? 1).toDouble(),
        1,
        props: series.animatorProps,
      );
      tween2.addListener(() {
        old.textConfig = old.textConfig?.copyWith(scaleFactor: tween2.value);
        invalidate();
      });
      tl.add(tween2);
    }
    if (hoverNode != null) {
      var node = hoverNode;
      AreaStyle style = series.areaStyleFun.call(node).convert(node.status);
      AreaStyleTween tween = AreaStyleTween(oldMap[node]!, style, props: series.animatorProps);
      tween.addListener(() {
        node.areaStyle = tween.value;
        invalidate();
      });
      tl.add(tween);
      ChartDoubleTween tween2 =
          ChartDoubleTween.fromValue((node.textConfig?.scaleFactor ?? 1).toDouble(), 1.5, props: series.animatorProps);
      tween2.addListener(() {
        node.textConfig = node.textConfig?.copyWith(scaleFactor: tween2.value);
        invalidate();
      });
      tl.add(tween2);
    }
    if (tl.isEmpty) {
      invalidate();
      return;
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  void handleCancel() {
    if (oldNode == null) {
      return;
    }
    List<ChartTween> tl = [];
    var old = oldNode!;
    oldNode = null;
    AreaStyle oldStyle = old.areaStyle;
    old.removeState(ViewState.hover);
    AreaStyle style = series.areaStyleFun.call(old).convert(old.status);
    AreaStyleTween tween = AreaStyleTween(oldStyle, style, props: series.animatorProps);
    tween.addListener(() {
      old.areaStyle = tween.value;
      invalidate();
    });
    tl.add(tween);
    ChartDoubleTween tween2 = ChartDoubleTween.fromValue(
      (old.textConfig?.scaleFactor ?? 1).toDouble(),
      1,
      props: series.animatorProps,
    );
    tween2.addListener(() {
      old.textConfig = old.textConfig?.copyWith(scaleFactor: tween2.value);
    });
    tl.add(tween2);
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.dataList, width, height);
  }

  @override
  void onDraw(Canvas canvas) {
    List<FunnelNode> nodeList = _layout.nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    for (var node in nodeList) {
      node.areaStyle.drawPath(canvas, mPaint, node.path);
    }
    for (var node in nodeList) {
      _drawText(canvas, node);
    }
  }

  void _drawText(Canvas canvas, FunnelNode node) {
    TextDrawConfig? config = node.textConfig;
    DynamicText? label = node.data.label;
    if (label == null || label.isEmpty || config == null) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node);
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
