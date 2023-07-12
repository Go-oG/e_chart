import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_layout.dart';

/// 单个盒须图
class BoxPlotView extends CoordChildView<BoxplotSeries> implements GridChild {
  final BoxplotLayout _layout = BoxplotLayout();

  BoxPlotView(super.series);

  @override
  void onClick(Offset offset) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverEnd() {
    _layout.clearHover();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.update);
  }

  @override
  void onStart() {
    super.onStart();
    _layout.addListener(invalidate);
  }

  @override
  void onStop() {
    _layout.clearListener();
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    var of = context.findGridCoord().getTranslation();
    var chartTheme = context.config.theme;
    var theme = chartTheme.boxplotTheme;
    canvas.save();
    canvas.translate(of.dx, of.dy);
    each(_layout.nodeList, (node, p1) {
      AreaStyle? areaStyle;
      if (series.areaStyleFun != null) {
        areaStyle = series.areaStyleFun?.call(node.data);
      } else {
        if (theme.fillColor != null) {
          areaStyle = AreaStyle(color: theme.fillColor).convert(node.status);
        }
      }
      areaStyle?.drawPath(canvas, mPaint, node.areaPath);
      LineStyle? style;
      if (series.lineStyleFun != null) {
        style = series.lineStyleFun?.call(node.data);
      } else {
        style = LineStyle(color: theme.borderColor, width: theme.borderWidth).convert(node.status);
      }
      style?.drawPath(canvas, mPaint, node.path, true);
    });
    canvas.restore();
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
   return series.data.length;
  }

  @override
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      if(isXAxis){
        dl.add(element.x);
      }else{
        dl.add(element.min);
        dl.add(element.max);
      }
    }
    return dl;
  }

  @override
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    // TODO: implement getAxisMaxText
    throw UnimplementedError();
  }
}
