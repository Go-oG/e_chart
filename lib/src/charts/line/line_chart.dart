import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/grid_helper.dart';
import 'package:e_chart/src/charts/line/helper/polar_helper.dart';
import 'package:e_chart/src/component/theme/chart/line_theme.dart';

import 'helper/line_helper.dart';
import 'line_node.dart';

class LineView extends CoordChildView<LineSeries> with GridChild, PolarChild {
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
  ChartLayout<ChartSeries, dynamic>? getLayoutHelper() => layoutHelper;

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
    double t = helper.getAnimatorPercent();
    if (t != 1) {
      clipRect = Rect.fromLTWH(clipRect.left, clipRect.top, clipRect.width * t, clipRect.height);
    }

    var lineList = helper.getLineNodeList();
    var theme = context.option.theme.lineTheme;
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
    double t = helper.getAnimatorPercent();
    if (t == 0) {
      return;
    }
    Offset offset = layoutHelper.getTranslation();
    var lineList = helper.getLineNodeList();
    var theme = context.option.theme.lineTheme;
    canvas.save();
    canvas.translate(offset.dx, 0);
    each(lineList, (lineNode, p1) {
      bool needSymbol = series.symbolFun != null || theme.showSymbol;
      List<SymbolNode> symbolList = drawLineForPolar(canvas, lineNode, theme, t, needSymbol);
      if (needSymbol && symbolList.isNotEmpty) {
        drawSymbolForPolar(canvas, symbolList, theme);
      }
    });
    canvas.restore();
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

  List<SymbolNode> drawLineForPolar(Canvas canvas, LineNode lineNode, LineTheme theme, double percent, bool needSymbol) {
    if (lineNode.borderList.isEmpty) {
      return [];
    }

    var ls = layoutHelper.buildLineStyle(null, lineNode.data, lineNode.groupIndex, null);
    lineNode.lineStyle = ls;
    Set<SymbolNode> symbolSet = {};
    for (var border in lineNode.borderList) {
      var path = border.path.percentPath(percent);
      drawAreaForPolar(canvas, lineNode, path, theme);
      ls?.drawPath(canvas, mPaint, path, needSplit: false);
      if (!needSymbol) {
        continue;
      }
      for (var symbol in lineNode.symbolMap.values) {
        if (path.contains(symbol.offset)) {
          symbolSet.add(symbol);
        }
      }
    }
    return List.from(symbolSet);
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

  void drawAreaForPolar(Canvas canvas, LineNode node, Path path, LineTheme theme) {
    var style = layoutHelper.buildAreaStyle(null, node.data, node.groupIndex, null);
    node.areaStyle = style;
    if (style == null) {
      return;
    }
    Offset center = layoutHelper.findPolarCoord().getCenter();
    path.lineTo(center.dx, center.dy);
    path.close();
    style.drawPath(canvas, mPaint, path);
  }

  void drawSymbol(Canvas canvas, LineNode lineNode, Rect clipRect, LineTheme theme) {
    lineNode.symbolMap.forEach((key, node) {
      if (!clipRect.contains(node.offset)) {
        return;
      }
      if (series.symbolFun != null) {
        ChartSymbol? symbol = series.symbolFun?.call(node.data, node.group);
        symbol?.draw(canvas, mPaint, node.offset);
      } else if (theme.showSymbol) {
        theme.symbol.draw(canvas, mPaint, node.offset);
      }
    });
  }

  void drawSymbolForPolar(Canvas canvas, List<SymbolNode> symbolList, LineTheme theme) {
    each(symbolList, (symbol, p1) {
      if (series.symbolFun != null) {
        ChartSymbol? cs = series.symbolFun?.call(symbol.data, symbol.group);
        cs?.draw(canvas, mPaint, symbol.offset);
      } else if (theme.showSymbol) {
        theme.symbol.draw(canvas, mPaint, symbol.offset);
      }
    });
  }

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

  @override
  List<DynamicData> getAngleDataSet() {
    return getAxisExtreme(0, false);
  }

  @override
  List<DynamicData> getRadiusDataSet() {
    return getAxisExtreme(0, true);
  }
}
