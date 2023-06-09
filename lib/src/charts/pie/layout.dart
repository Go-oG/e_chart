import 'package:flutter/material.dart';

import '../../ext/offset_ext.dart';
import '../../model/dynamic_text.dart';
import '../../model/enums/circle_align.dart';
import '../../model/group_data.dart';
import '../../model/text_position.dart';
import '../../shape/arc.dart';
import '../../style/label.dart';
import '../../utils/align_util.dart';
import 'pie_series.dart';

///饼图构造者
class PieLayers {
  List<PieNode> _nodeList = [];
  num maxData = 0;
  num minData = 0;
  num allData = 0;
  num minRadius = 0;
  num maxRadius = 0;

  List<PieNode> layout(
    List<ItemData> list,
    PieSeries series,
    num minRadius,
    num maxRadius,
    num canvasWidth,
    num canvasHeight,
  ) {
    this.minRadius = minRadius;
    this.maxRadius = maxRadius;
    List<PieNode> nodeList = [];
    for (int i = 0; i < list.length; i++) {
      var ele = list[i];
      nodeList.add(PieNode.fromPieData(ele, series, minRadius, maxRadius, canvasWidth, canvasHeight));
      if (ele.value > maxData) {
        maxData = ele.value;
      }
      if (ele.value < minData) {
        minData = ele.value;
      }
      allData += ele.value;
    }
    _nodeList = nodeList;
    layoutInner(series);
    return _nodeList;
  }

  void layoutInner(PieSeries series) {
    if (series.roseType == RoseType.normal) {
      _layoutForNormal(series);
    } else {
      _layoutForNightingale(series);
    }
  }

  //普通饼图
  void _layoutForNormal(PieSeries series) {
    int count = _nodeList.length;
    num gapAllAngle = count * series.angleGap;
    num remainAngle = 360 - gapAllAngle;
    num startAngle = series.offsetAngle;
    num outerRadius = maxRadius;
    if (outerRadius <= minRadius) {
      outerRadius = minRadius + 1;
    }

    int direction = series.clockWise ? 1 : -1;

    for (int i = 0; i < count; i++) {
      PieNode node = _nodeList[i];
      var pieData = node.data;
      double sweepAngle = remainAngle * pieData.value / allData;
      PieProps props = PieProps();
      props.ir = minRadius;
      props.or = outerRadius;
      props.startAngle = startAngle;
      props.sweepAngle = sweepAngle * direction;
      props.corner = series.corner;
      node.cur = props;
      node.start = props;
      node.end = props;
      startAngle += (sweepAngle + series.angleGap) * direction;
    }
  }

  // 南丁格尔玫瑰图
  void _layoutForNightingale(PieSeries series) {
    int count = _nodeList.length;
    double gapAllAngle = count * series.angleGap;
    double remainAngle = 360 - gapAllAngle;
    double startAngle = series.offsetAngle;
    int direction = series.clockWise ? 1 : -1;
    if (series.roseType == RoseType.area) {
      // 所有扇区圆心角相同，通过半径展示数据大小
      double itemAngle = remainAngle / count;
      for (int i = 0; i < count; i++) {
        PieNode node = _nodeList[i];
        var pieData = node.data;
        double percent = pieData.value / maxData;
        PieProps props = PieProps();
        props.ir = minRadius;
        props.or = maxRadius * percent;
        if (props.or <= props.ir) {
          props.or = props.ir + 1;
        }
        props.startAngle = startAngle;
        props.sweepAngle = itemAngle * direction;
        node.cur = props;
        node.start = props;
        node.end = props;
        startAngle += (itemAngle + series.angleGap) * direction;
      }
    } else {
      //扇区圆心角展示数据百分比，半径表示数据大小
      int count = _nodeList.length;
      for (int i = 0; i < count; i++) {
        PieNode node = _nodeList[i];
        PieProps props = PieProps();
        props.ir = minRadius;
        props.corner = series.corner;
        node.cur = props;
        node.start = props;
        node.end = props;
        ItemData pieData = node.data;
        props.or = maxRadius * pieData.value / maxData;
        double sweepAngle = remainAngle * (pieData.value / allData);
        if (props.or <= props.ir) {
          props.or = props.ir + 1;
        }
        props.startAngle = startAngle;
        props.sweepAngle = sweepAngle + direction;
        startAngle += (sweepAngle + series.angleGap) * direction;
      }
    }
  }
}

class PieNode {
  final ItemData data;
  final DynamicText? label;
  final LabelStyle? labelStyle;
  final num maxRadius;
  final num minRadius;
  final num canvasWidth;
  final num canvasHeight;
  final num padAngle;

  PieProps cur = PieProps();
  PieProps start = PieProps();
  PieProps end = PieProps();

  PieNode(
    this.data,
    this.label,
    this.labelStyle,
    this.minRadius,
    this.maxRadius,
    this.canvasWidth,
    this.canvasHeight,
    this.padAngle,
  );

  static PieNode fromPieData(
    ItemData data,
    PieSeries series,
    num minRadius,
    num maxRadius,
    num canvasWidth,
    num canvasHeight,
  ) {
    return PieNode(
      data,
      data.label,
      series.labelStyleFun?.call(data, null),
      minRadius,
      maxRadius,
      canvasWidth,
      canvasHeight,
      series.angleGap,
    );
  }

  Path toPath() {
    Arc arc = Arc(
      innerRadius: cur.ir,
      outRadius: cur.or,
      startAngle: cur.startAngle,
      sweepAngle: cur.sweepAngle,
      cornerRadius: cur.corner,
      padAngle: padAngle,
    );
    return arc.toPath(true);
  }

  ///计算文字的位置
  TextDrawConfig? computeTextPosition(PieSeries series) {
    if (label == null || label!.isEmpty || labelStyle == null || !labelStyle!.show) {
      return null;
    }

    if (series.labelAlign == CircleAlign.center) {
      return TextDrawConfig(Offset.zero, align: Alignment.center);
    }

    if (series.labelAlign == CircleAlign.inside) {
      double radius = (cur.ir + cur.or) / 2;
      double angle = cur.startAngle + cur.sweepAngle / 2;
      Offset offset = circlePoint(radius, angle);
      return TextDrawConfig(offset, align: Alignment.center);
    }

    if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle!.guideLine.length;
      double centerAngle = cur.startAngle + cur.sweepAngle / 2;

      centerAngle %= 360;
      if (centerAngle < 0) {
        centerAngle += 360;
      }

      Offset offset = circlePoint(cur.or + expand, centerAngle);
      Alignment align = toAlignment(centerAngle, false);
      if (centerAngle >= 90 && centerAngle <= 270) {
        offset = offset.translate(-(expand + labelStyle!.lineMargin), 0);
        align = Alignment.centerRight;
      } else {
        offset = offset.translate(expand + labelStyle!.lineMargin, 0);
        align = Alignment.centerLeft;
      }
      return TextDrawConfig(offset, align: align);
    }
    return null;
  }
}

class PieProps {
  num corner = 0;
  num ir = 0; //内圆半径(<=0时为圆)
  num or = 0; //外圆最大半径(<=0时为圆)
  num startAngle = 0; //开始角度
  num sweepAngle = 0; //扫过的角度(<=0时为圆)
  bool select = false;

  PieProps clone() {
    PieProps props = PieProps();
    props.corner = corner;
    props.ir = ir;
    props.or = or;
    props.startAngle = startAngle;
    props.sweepAngle = sweepAngle;
    props.select = select;
    return props;
  }

  @override
  String toString() {
    return 'ir:${ir.toStringAsFixed(1)} or:${or.toStringAsFixed(1)}'
        ' startAngle:${startAngle.toStringAsFixed(1)}'
        ' endAngle:${(startAngle + sweepAngle).toStringAsFixed(1)}';
  }

  double get endAngle => (startAngle + sweepAngle).toDouble();
}
