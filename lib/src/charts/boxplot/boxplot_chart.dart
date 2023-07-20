import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_layout.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_node.dart';

/// 单个盒须图
class BoxPlotView extends CoordChildView<BoxplotSeries> with GridChild {
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
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutType.update);
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
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    var of = context.findGridCoord().getTranslation();
    canvas.save();
    canvas.translate(of.dx, of.dy);
    each(_layout.nodeList, (group, p1) {
      each(group.nodeList, (node, i) {
        getAreaStyle(node, group, p1)?.drawPath(canvas, mPaint, node.areaPath);
        getBorderStyle(node, group, p1).drawPath(canvas, mPaint, node.path);
      });
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
    for (var group in series.data) {
      for (var element in group.data) {
        if (isXAxis) {
          dl.add(element.x);
        } else {
          dl.add(element.min);
          dl.add(element.max);
        }
      }
    }
    return dl;
  }

  AreaStyle? getAreaStyle(BoxplotNode node, BoxplotGroupNode group, int index) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(node.data, group.data);
    }
    var chartTheme = context.config.theme;
    Color fillColor = chartTheme.getColor(index);
    return AreaStyle(color: fillColor).convert(node.status);
  }

  LineStyle getBorderStyle(BoxplotNode node, BoxplotGroupNode group, int index) {
    if (series.borderStyleFun != null) {
      return series.borderStyleFun!.call(node.data, group.data);
    }
    var theme = context.config.theme.boxplotTheme;
    return theme.getBorderStyle(context.config.theme, index).convert(node.status);
  }
}
