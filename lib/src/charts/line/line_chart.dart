import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'layout_helper.dart';

class LineView extends CoordChildView<LineSeries> with GridChild {
  final LineLayoutHelper helper = LineLayoutHelper();

  ///用户优化视图绘制
  LineView(super.series);

  @override
  void onHoverStart(Offset offset) {
    helper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    helper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverEnd() {
    helper.clearHover();
  }

  @override
  void onClick(Offset offset) {
    helper.handleHoverOrClick(offset, true);
  }

  @override
  void onStart() {
    super.onStart();
    helper.addListener(invalidate);
  }

  @override
  void onStop() {
    helper.removeListener(invalidate);
    super.onStop();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    helper.doMeasure(context, series, series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    helper.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    var chartTheme = context.config.theme;
    var theme = chartTheme.lineTheme;
    final List<LineResult> list = helper.lineList;

    ///这里分开绘制是为了避免边框被遮挡
    each(list, (result, i) {
      AreaStyle? style = helper.getAreaStyle(result.data, i);
      result.areaStyle = style;
      if (style != null) {
        for (var path in result.areaPathList) {
          style.drawPath(canvas, mPaint, path);
        }
      }
    });
    each(list, (result, i) {
      var ls = helper.getLineStyle(result.data, i);
      result.lineStyle = ls;
      if (ls != null) {
        for (var path in result.borderPathList) {
          ls.drawPath(canvas, mPaint, path);
        }
      }
    });

    if (series.symbolFun != null || theme.showSymbol) {
      ///绘制symbol
      SymbolDesc desc = SymbolDesc();
      each(list, (result, p1) {
        each(result.data.data, (data, i) {
          if (data == null || i >= result.offsetList.length) {
            return;
          }
          var offset = result.offsetList[i];
          if (offset == null) {
            return;
          }

          desc.center = offset;
          ChartSymbol? symbol = series.symbolFun?.call(data, result.data);
          if (symbol != null) {
            symbol.draw(canvas, mPaint, desc);
          } else if (theme.showSymbol) {
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
    return helper.getAxisExtreme(series, axisIndex, isXAxis);
  }
}
