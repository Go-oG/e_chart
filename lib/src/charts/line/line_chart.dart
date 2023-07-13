import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'layout_helper.dart';

class LineView extends CoordChildView<LineSeries> implements GridChild {
  final LineLayoutHelper layoutHelper = LineLayoutHelper();

  ///用户优化视图绘制
  LineView(super.series);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    layoutHelper.doMeasure(context, series, series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    var chartTheme = context.config.theme;
    var theme = chartTheme.lineTheme;
    final List<LineResult> list = layoutHelper.lineList;
    Map<LineGroupData, AreaStyle> styleMap = {};

    ///这里分开绘制是为了避免边框被遮挡
    each(list, (result, i) {
      AreaStyle? style = series.styleFun?.call(result.data,i);
      if (style == null) {
        Color color = chartTheme.colors[i % chartTheme.colors.length];
        style = AreaStyle(
          color: theme.fill ? color.withOpacity(theme.opacity) : null,
          border: LineStyle(color: color, width: theme.lineWidth, dash: theme.dashList),
        );
      }
      styleMap[result.data] = style;
      style.drawPath(canvas, mPaint, result.areaPath, false);
    });
    each(list, (result, i) {
      AreaStyle style = styleMap[result.data]!;
      style.border?.drawPath(canvas, mPaint, result.borderPath);
    });
    if (series.symbolFun != null || theme.showSymbol) {
      ///绘制symbol
      SymbolDesc desc=SymbolDesc();
      each(list, (result, p1) {
        each(result.data.data, (data, i) {
          ChartSymbol? symbol=series.symbolFun?.call(data,result.data);
          if(symbol!=null){
            desc.center=layoutHelper.getNodePosition(data);
            symbol.draw(canvas, mPaint, desc);
          }else if(theme.showSymbol){
            desc.center=layoutHelper.getNodePosition(data);
            theme.symbol.draw(canvas, mPaint, desc);
          }
        });
      });
    }
  }

  /// 绘制柱状图
  void drawBarElement(Canvas canvas) {}

  /// 绘制标记点
  void drawMakePoint(Canvas canvas) {}

  /// 绘制标记线
  void drawMakeLine(Canvas canvas) {}

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    int count = 0;
    for (var data in series.data) {
      if (data.data.length > count) {
        count = data.data.length;
      }
    }
    return count;
  }

  @override
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisExtreme(series, axisIndex, isXAxis);
  }

  @override
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisMaxText(series, axisIndex, isXAxis);
  }
}
