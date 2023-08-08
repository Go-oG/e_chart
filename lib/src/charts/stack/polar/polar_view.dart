import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import '../stack_view.dart';

abstract class PolarView<T extends StackItemData, G extends StackGroupData<T>, S extends StackSeries<T, G>, L extends PolarHelper<T, G, S>>
    extends StackView<T, G, S, L> with PolarChild {
  PolarView(super.series);

  @override
  void drawGroupBk(Canvas canvas) {
    Set<GroupNode> rectSet = {};
    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, 0);
    var nodeMap = layoutHelper.showNodeMap;
    nodeMap.forEach((key, node) {
      var group = node.parentNode.parentNode;
      if (rectSet.contains(group)) {
        return;
      }
      AreaStyle? style;
      if (series.groupStyleFun != null) {
        style = series.groupStyleFun?.call(node.data, node.parent, node.status);
      } else if (group.isHover) {
        style = s2;
      }
      style?.drawPath(canvas, mPaint, group.arc.toPath(false));
      rectSet.add(group);
    });
    canvas.restore();
    return;
  }

  @override
  void drawBar(Canvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (node.arc.isEmpty) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      var as = layoutHelper.buildAreaStyle(data, group, node.groupIndex, node.status);

      var ls = layoutHelper.buildLineStyle(data, group, node.groupIndex, node.status);
      node.areaStyle = as;
      node.lineStyle = ls;
      if (as == null && ls == null) {
        return;
      }
      as?.drawPath(canvas, mPaint, node.arc.toPath(true));
      ls?.drawPath(canvas, mPaint, node.arc.toPath(true));
    });
    canvas.restore();
  }

  @override
  void drawBarLabel(Canvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (node.arc.isEmpty) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      LabelStyle? style = series.getLabelStyle(context, data, group);
      if (style == null || !style.show) {
        return;
      }
      DynamicText? text = series.formatData(context, data, group);
      if (text == null || text.isEmpty) {
        return;
      }
      ChartAlign align = series.getLabelAlign(context, data, group);
      TextDrawInfo drawInfo = align.convert(node.rect, style, series.direction);
      style.draw(canvas, mPaint, text, drawInfo);
    });
    canvas.restore();
  }

  @override
  List<DynamicData> getAngleExtreme() {
    return layoutHelper.getAxisExtreme(series, 0, false);
  }

  @override
  List<DynamicData> getRadiusExtreme() {
    return layoutHelper.getAxisExtreme(series, 0, true);
  }
}
