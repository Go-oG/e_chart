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
    radarLayout.doLayout(context, series, series.data, selfBoxBound, LayoutType.update);
    _initAnimator();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    radarLayout.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
    _initAnimator();
  }

  void _initAnimator() {
    AnimatorAttrs? info = series.animation;
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
    var nodeList = radarLayout.groupNodeList;
    each(nodeList, (group, i) {
      if (!group.data.show) {
        return;
      }

      AreaStyle? areaStyle = getAreaStyle(group, i);
      LineStyle? lineStyle = getLineStyle(group, i);
      bool drawSymbol = series.symbolFun != null || theme.showSymbol;
      if (areaStyle == null && lineStyle == null && !drawSymbol) {
        return;
      }
      List<Offset> ol = group.getPathOffset();
      areaStyle?.drawPolygonArea(canvas, mPaint, ol);
      lineStyle?.drawPolygon(canvas, mPaint, ol, true);

      if (!drawSymbol) {
        return;
      }

      SymbolDesc desc = SymbolDesc();
      for (int i = 0; i < ol.length; i++) {
        desc.center = ol[i];
        ChartSymbol? symbol;
        if (series.symbolFun != null) {
          symbol = series.symbolFun?.call(group.nodeList[i].data, i, group.data);
          symbol?.draw(canvas, mPaint, desc);
        } else {
          symbol = theme.showSymbol ? theme.symbol : null;
          symbol?.draw(canvas, mPaint, desc);
        }
      }

    });
  }

  AreaStyle? getAreaStyle(RadarGroupNode group, int index) {
    var theme = context.config.theme.radarTheme;
    var chartTheme = context.config.theme;

    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(group.data);
    } else if (theme.fill) {
      Color fillColor = chartTheme.getColor(index);
      return AreaStyle(color: fillColor);
    }
    return null;
  }

  LineStyle? getLineStyle(RadarGroupNode group, int index) {
    var theme = context.config.theme.radarTheme;
    var chartTheme = context.config.theme;
    LineStyle? lineStyle;
    if (series.lineStyleFun != null) {
      lineStyle = series.lineStyleFun?.call(group.data);
    } else if (theme.lineWidth > 0) {
      Color lineColor = chartTheme.getColor(index);
      lineStyle = LineStyle(color: lineColor, width: theme.lineWidth, dash: theme.dashList);
    }
    return lineStyle;
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
