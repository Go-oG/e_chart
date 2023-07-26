import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/helper/base_stack_helper.dart';
import 'package:e_chart/src/charts/line/helper/grid_helper.dart';
import 'package:e_chart/src/charts/line/helper/polar_helper.dart';
import 'package:e_chart/src/component/theme/chart/line_theme.dart';

import 'helper/line_helper.dart';
import 'line_node.dart';

class LineView extends CoordChildView<LineSeries> with GridChild {
  late BaseStackLayoutHelper<LineItemData, LineGroupData, LineSeries> layoutHelper;
  late LineHelper helper;

  LineView(super.series) {
    if (series.coordSystem == CoordSystem.polar) {
      var h = LinePolarHelper();
      layoutHelper = h;
      helper = h;
    } else {
      var h = LineGridHelper();
      layoutHelper = h;
      helper = h;
    }
  }

  @override
  void onHoverStart(Offset offset) {
    layoutHelper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    layoutHelper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverEnd() {
    layoutHelper.clearHover();
  }

  @override
  void onClick(Offset offset) {
    layoutHelper.handleHoverOrClick(offset, true);
  }

  @override
  void onStart() {
    super.onStart();
    layoutHelper.addListener(invalidate);
  }

  @override
  void onStop() {
    layoutHelper.removeListener(invalidate);
    super.onStop();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    layoutHelper.doMeasure(context, series, series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    if (series.coordSystem == CoordSystem.polar) {
      drawForPolar(canvas);
    } else {
      drawForGrid(canvas);
    }
  }

  void drawForGrid(Canvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    Rect clipRect = Rect.fromLTWH(offset.dx.abs(), 0, width, height);
    var lineList = helper.getLineNodeList();
    var theme = context.config.theme.lineTheme;
    canvas.save();
    canvas.translate(offset.dx, 0);
    canvas.clipRect(clipRect);
    each(lineList, (lineNode, p1) {
      drawArea(canvas, lineNode, clipRect, offset, theme);
      drawLine(canvas, lineNode, clipRect, theme);
      if (series.symbolFun != null || theme.showSymbol) {
        drawSymbol(canvas, lineNode, clipRect, theme);
      }
    });
    canvas.restore();
  }

  void drawForPolar(Canvas canvas) {
    ///TODO 待实现
  }

  void drawLine(Canvas canvas, LineNode lineNode, Rect clipRect, LineTheme theme) {
    if (lineNode.borderList.isEmpty) {
      return;
    }
    var ls = layoutHelper.buildLineStyle(null, lineNode.data, lineNode.groupIndex, null);
    if (ls == null) {
      return;
    }
    lineNode.lineStyle = ls;
    for (var border in lineNode.borderList) {
      if (!clipRect.overlaps(border.rect)) {
        continue;
      }
      for (var subPath in border.subPathList) {
        if (!clipRect.overlaps(subPath.bound)) {
          continue;
        }
        ls.drawPath(canvas, mPaint, subPath.path, needSplit: false, drawDash: false);
      }
    }
  }

  void drawArea(Canvas canvas, LineNode lineNode, Rect clipRect, Offset scroll, LineTheme theme) {
    if (lineNode.areaList.isEmpty) {
      return;
    }
    var style = layoutHelper.buildAreaStyle(null, lineNode.data, lineNode.groupIndex, null);
    if (style == null) {
      return;
    }
    lineNode.areaStyle = style;

    for (var area in lineNode.areaList) {
      style.drawPath(canvas, mPaint, area.originPath);
    }
  }

  void drawSymbol(Canvas canvas, LineNode lineNode, Rect clipRect, LineTheme theme) {
    SymbolDesc desc = SymbolDesc();
    lineNode.symbolMap.forEach((key, node) {
      if (!clipRect.contains(node.offset)) {
        return;
      }
      var cl = layoutHelper.buildLineStyle(null, node.group, node.groupIndex, null)?.color;
      if (cl != null) {
        desc.fillColor = [cl];
      }
      desc.center = node.offset;
      if (series.symbolFun != null) {
        ChartSymbol? symbol = series.symbolFun?.call(node.data, node.group);
        symbol?.draw(canvas, mPaint, desc);
      } else if (theme.showSymbol) {
        theme.symbol.draw(canvas, mPaint, desc);
      }
    });
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
  void onGridScrollChange(Offset scroll) {
    layoutHelper.onGridScrollChange(scroll);
  }

  @override
  void onGridScrollEnd(Offset scroll) {
    super.onGridScrollEnd(scroll);
    layoutHelper.onGridScrollEnd(scroll);
  }
}
