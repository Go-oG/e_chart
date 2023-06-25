import 'package:flutter/material.dart';

import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../animation/tween/offset_tween.dart';
import '../../coord/radar/radar_child.dart';
import '../../core/command.dart';
import '../../core/view.dart';
import '../../style/area_style.dart';
import '../../style/symbol/symbol.dart';
import 'layout.dart';
import 'radar_series.dart';

/// 雷达图
class RadarView extends ChartView implements RadarChild {
  final RadarSeries series;
  final RadarLayout radarLayout = RadarLayout();

  RadarView(this.series);

  @override
  void onUpdateDataCommand(covariant Command c) {
    radarLayout.doLayout(context, series, series.data);
    _initAnimator();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    radarLayout.doLayout(context, series, series.data);
    _initAnimator();
  }

  void _initAnimator() {
    AnimatorProps? info = series.animation;
    List<RadarGroupNode> nodeList = radarLayout.groupNodeList;
    if (info != null) {
      for (var group in nodeList) {
        for (var node in group.nodeList) {
          node.start = Offset.zero;
          node.end = node.cur;
          node.cur = Offset.zero;
        }
      }
      OffsetTween offsetTween = OffsetTween(Offset.zero, Offset.zero);
      ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
      tween.addListener(() {
        for (var group in nodeList) {
          for (var node in group.nodeList) {
            offsetTween.changeValue(node.start, node.end);
            node.cur = offsetTween.safeGetValue(tween.value);
          }
        }
        invalidate();
      });
      tween.start(context);
    }
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(width / 2, height / 2);
    _drawData(canvas);
    canvas.restore();
  }

  void _drawData(Canvas canvas) {
    for (var group in radarLayout.groupNodeList) {
      if (!group.show) {
        continue;
      }
      AreaStyle style = series.areaStyleFun.call(group.data);
      if (!style.show) {
        continue;
      }
      List<Offset> ol = group.getPathOffset();
      style.drawPolygonArea(canvas, mPaint, ol);
      for (int i = 0; i < ol.length; i++) {
        ChartSymbol? symbol = series.symbolFun?.call(group.nodeList[i].data, i, group.data);
        symbol?.draw(canvas, mPaint, ol[i]);
      }
    }
  }

  @override
  List<num> dataSet(int dim) {
    List<num> resultList = [];
    for (var group in series.data) {
      if (group.childData.length > dim) {
        resultList.add(group.childData[dim].value);
      }
    }
    return resultList;
  }

  @override
  int get radarIndex => series.radarIndex;
}
