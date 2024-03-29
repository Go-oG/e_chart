import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'radar_helper.dart';
import 'radar_node.dart';

/// 雷达图
class RadarView extends SeriesView<RadarSeries, RadarHelper> implements RadarChild {
  RadarView(super.series);

  @override
  void onUpdateDataCommand(covariant Command c) {
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.update);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    ChartTheme chartTheme = context.option.theme;
    RadarTheme theme = chartTheme.radarTheme;
    var nodeList = layoutHelper.groupNodeList;
    each(nodeList, (group, i) {
      if (!group.data.show) {
        return;
      }

      Path? path = group.pathOrNull;
      if (path != null) {
        AreaStyle? areaStyle = getAreaStyle(group, group.groupIndex);
        areaStyle?.drawPath(canvas, mPaint, path);
        LineStyle? lineStyle = getLineStyle(group, group.groupIndex);
        lineStyle?.drawPath(canvas, mPaint, path, drawDash: true, needSplit: false);
      }

      if (series.symbolFun == null || !theme.showSymbol) {
        return;
      }

      for (int i = 0; i < group.nodeList.length; i++) {
        var center = group.nodeList[i].attr;
        ChartSymbol? symbol;
        if (series.symbolFun != null) {
          symbol = series.symbolFun?.call(group.nodeList[i].data, i, group.data);
          symbol?.draw(canvas, mPaint, center);
        } else {
          symbol = theme.showSymbol ? theme.symbol : null;
          symbol?.draw(canvas, mPaint, center);
        }
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

  AreaStyle? getAreaStyle(RadarGroupNode group, int index) {
    var theme = context.option.theme.radarTheme;
    var chartTheme = context.option.theme;
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(group.data);
    } else if (theme.fill) {
      Color fillColor = chartTheme.getColor(index);
      return AreaStyle(color: fillColor);
    }
    return null;
  }

  LineStyle? getLineStyle(RadarGroupNode group, int index) {
    var chartTheme = context.option.theme;
    var theme = chartTheme.radarTheme;
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
  RadarHelper buildLayoutHelper() {
    return RadarHelper(context, series);
  }
}
