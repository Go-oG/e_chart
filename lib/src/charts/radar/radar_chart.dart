import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'layout.dart';

/// 雷达图
class RadarView extends SeriesView<RadarSeries> implements RadarChild {
  final RadarLayout radarLayout = RadarLayout();

  RadarView(super.series);

  @override
  void onUpdateDataCommand(covariant Command c) {
    radarLayout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.update);
    _initAnimator();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    radarLayout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
    _initAnimator();
  }

  void _initAnimator() {
    AnimatorProps? info = series.animation;
    List<RadarGroupNode> nodeList = radarLayout.groupNodeList;
    if (info != null) {
      for (var group in nodeList) {
        for (var node in group.nodeList) {
          node.start = radarLayout.center;
          node.end = node.cur;
          node.cur = Offset.zero;
        }
      }
      OffsetTween offsetTween = OffsetTween(Offset.zero, Offset.zero);
      ChartDoubleTween tween = ChartDoubleTween(props: series.animatorProps);
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
    ChartTheme chartTheme = context.config.theme;
    RadarTheme theme = chartTheme.radarTheme;
    each(radarLayout.groupNodeList, (group, i) {
      if (!group.show) {
        return;
      }
      AreaStyle? style;
      if (series.areaStyleFun != null) {
        style = series.areaStyleFun?.call(group.data);
      } else {
        Color spColor;
        Color borderColor;
        if (theme.splitColors.isNotEmpty) {
          spColor = theme.splitColors[i % theme.splitColors.length];
        } else {
          spColor = chartTheme.colors[i % chartTheme.colors.length];
        }
        if (theme.borderColors.isNotEmpty) {
          borderColor = theme.borderColors[i % theme.borderColors.length];
        } else {
          borderColor = chartTheme.colors[i % chartTheme.colors.length];
        }
        style = AreaStyle(color: spColor, border: LineStyle(color: borderColor, width: theme.lineWidth));
      }

      if (style == null || !style.show) {
        return;
      }

      List<Offset> ol = group.getPathOffset();
      style.drawPolygonArea(canvas, mPaint, ol);
      for (int i = 0; i < ol.length; i++) {
        ChartSymbol? symbol;
        if (series.symbolFun != null) {
          symbol = series.symbolFun?.call(group.nodeList[i].data, i, group.data);
        } else {
          symbol = theme.symbol;
        }
        symbol?.draw(canvas, mPaint, ol[i], 1);
      }
    });
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
