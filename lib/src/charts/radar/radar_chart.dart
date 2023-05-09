import 'package:flutter/material.dart';

import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../animation/tween/offset_tween.dart';
import '../../coord/radar/radar_child.dart';
import '../../core/view.dart';
import '../../style/area_style.dart';
import 'layout.dart';
import 'radar_series.dart';

/// 雷达图
class RadarView extends View implements RadarChild {
  final RadarSeries series;
  final RadarLayers _layers = RadarLayers();
  final List<RadarGroupNode> _groupNodeList = [];

  RadarView(this.series, {super.paint, super.zIndex = 0});

  @override
  void onAttach() {
    super.onAttach();
    AnimatorProps? info = series.animation;
    if (info != null) {
      for (var group in _groupNodeList) {
        for (var node in group.nodeList) {
          node.start = Offset.zero;
          node.end = node.cur;
          node.cur = Offset.zero;
        }
      }
      OffsetTween offsetTween = OffsetTween(Offset.zero, Offset.zero);
      ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
      tween.addListener(() {
        for (var group in _groupNodeList) {
          for (var node in group.nodeList) {
            offsetTween.changeValue(node.start, node.end);
            node.cur = offsetTween.safeGetValue(tween.value);
          }
        }
        invalidate();
      });
      tween.start(context.tickerProvider);
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    _groupNodeList.clear();
    for (var element in series.data) {
      _groupNodeList.add(_layers.layout(this, element));
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
    for (var group in _groupNodeList) {
      if (!group.data.show) {
        continue;
      }
      AreaStyle? style = series.areaStyleFun.call(group.data, null);
      if (style == null || !style.show) {
        continue;
      }
      style.drawPolygonArea(canvas, paint, group.getPathOffset());
    }
  }

  @override
  List<num> dataSet(int dim) {
    List<num> resultList = [];
    for (var group in series.data) {
      if(group.dataList.length>dim){
        resultList.add(group.dataList[dim]);
      }
    }
    return resultList;
  }

  @override
  int get radarIndex => series.radarIndex;
}
