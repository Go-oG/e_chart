import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/material.dart';

import '../../action/user_action.dart';
import '../../core/context.dart';
import '../../core/layout.dart';
import '../../ext/offset_ext.dart';
import '../../model/enums/circle_align.dart';
import '../../model/group_data.dart';
import '../../model/string_number.dart';
import '../../model/text_position.dart';
import '../../shape/arc.dart';
import '../../style/label.dart';
import '../../utils/align_util.dart';
import 'pie_series.dart';

///饼图布局
class PieLayout extends ChartLayout {
  List<PieNode> _nodeList = [];
  num maxData = double.minPositive;
  num minData = double.maxFinite;
  num allData = 0;

  num minRadius = 0;
  num maxRadius = 0;
  num width = 0;
  num height = 0;

  PieLayout() : super();

  late PieSeries series;
  num pieAngle = 0;
  Offset center = Offset.zero;

  void doLayout(Context context, PieSeries series, List<ItemData> list, num width, num height) {
    this.series = series;
    this.width = width;
    this.height = height;
    pieAngle = adjustPieAngle(series.sweepAngle);
    center = _computeCenterPoint(series.center);
    preHandleRadius();
    _nodeList = preHandleData(list);
    layoutNode(_nodeList);
  }

  void layoutNode(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    if (series.roseType == RoseType.normal) {
      _layoutForNormal(nodeList);
    } else {
      _layoutForNightingale(nodeList);
    }
  }

  void preHandleRadius() {
    num maxSize = min([width, height]);
    minRadius = series.innerRadius.convert(maxSize);
    maxRadius = series.outerRadius.convert(maxSize);
    if (maxRadius < minRadius) {
      num a = maxRadius;
      maxRadius = minRadius;
      minRadius = a;
    }
  }

  List<PieNode> preHandleData(List<ItemData> list) {
    maxData = double.minPositive;
    minData = double.maxFinite;
    allData = 0;

    List<PieNode> nodeList = [];
    each(list, (data, i) {
      nodeList.add(PieNode(data, series.angleGap));
      maxData = max([data.value, maxData]);
      minData = min([data.value, minData]);
      allData += data.value;
    });
    if (allData == 0) {
      allData = 1;
    }
    return nodeList;
  }

  List<PieNode> get nodeList => _nodeList;

  //普通饼图
  void _layoutForNormal(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * series.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle < 0) {
      remainAngle = 1;
    }

    num startAngle = series.offsetAngle;
    int direction = series.clockWise ? 1 : -1;
    remainAngle *= direction;
    num angleGap = series.angleGap * direction;

    each(nodeList, (node, i) {
      var pieData = node.data;
      num sw = remainAngle * pieData.value / allData;
      node.props = PieProps(center: center, ir: minRadius, or: maxRadius, startAngle: startAngle, sweepAngle: sw, corner: series.corner);
      startAngle += sw + angleGap;
    });
  }

  // 南丁格尔玫瑰图
  void _layoutForNightingale(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * series.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle < 0) {
      remainAngle = 1;
    }
    double startAngle = series.offsetAngle;
    int direction = series.clockWise ? 1 : -1;
    double angleGap = series.angleGap.abs() * direction;
    if (series.roseType == RoseType.area) {
      // 所有扇区圆心角相同，通过半径展示数据大小
      double itemAngle = direction * remainAngle / count;
      each(nodeList, (node, i) {
        var pieData = node.data;
        double percent = pieData.value / maxData;
        node.props = PieProps(
          center: center,
          ir: minRadius,
          or: maxRadius * percent,
          corner: series.corner,
          startAngle: startAngle,
          sweepAngle: itemAngle,
        );
        startAngle += itemAngle + angleGap;
      });
    } else {
      //扇区圆心角展示数据百分比，半径表示数据大小
      each(nodeList, (node, i) {
        ItemData pieData = node.data;
        num or = maxRadius * pieData.value / maxData;
        double sweepAngle = direction * remainAngle * pieData.value / allData;
        node.props = PieProps(center: center, ir: minRadius, corner: series.corner, or: or, startAngle: startAngle, sweepAngle: sweepAngle);
        startAngle += sweepAngle + angleGap;
      });
    }
  }

  Offset _computeCenterPoint(List<SNumber> center) {
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    return Offset(x, y);
  }

  num adjustPieAngle(num angle) {
    if (angle <= 0) {
      return 1;
    }
    if (angle > 360) {
      return 360;
    }
    return angle.abs();
  }

  PieNode? findNode(Offset offset) {
    PieNode? node;
    for (var ele in nodeList) {
      PieProps cur = ele.props;
      if (offset.inSector(cur.ir, cur.or, cur.startAngle, cur.sweepAngle)) {
        node = ele;
        break;
      }
    }
    return node;
  }
}

class PieNode {
  final ItemData data;
  final num anglePad;
  bool select = false;

  PieProps props = const PieProps(center: Offset.zero, ir: 0, or: 0, startAngle: 0, sweepAngle: 0, corner: 0);

  PieNode(this.data, this.anglePad);

  Path toPath() {
    Arc arc = Arc(
      center: props.center,
      innerRadius: props.ir,
      outRadius: props.or,
      startAngle: props.startAngle,
      sweepAngle: props.sweepAngle,
      cornerRadius: props.corner,
      padAngle: anglePad,
    );
    return arc.toPath(true);
  }

  ///计算文字的位置
  TextDrawConfig? textDrawConfig;
  LabelStyle? labelStyle;

  void updateTextPosition(PieSeries series) {
    labelStyle = null;
    textDrawConfig = null;
    var label = data.label;
    if (label == null || label.isEmpty) {
      return;
    }
    labelStyle = series.labelStyleFun?.call(data, select ? UserAction(select: select) : null);
    if (labelStyle == null || !labelStyle!.show) {
      return;
    }
    if (series.labelAlign == CircleAlign.center) {
      textDrawConfig = TextDrawConfig(props.center, align: Alignment.center);
      return;
    }
    if (series.labelAlign == CircleAlign.inside) {
      double radius = (props.ir + props.or) / 2;
      double angle = props.startAngle + props.sweepAngle / 2;
      Offset offset = circlePoint(radius, angle).translate(props.center.dx, props.center.dy);
      textDrawConfig = TextDrawConfig(offset, align: Alignment.center);
      return;
    }
    if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle!.guideLine.length;
      double centerAngle = props.startAngle + props.sweepAngle / 2;
      Offset offset = circlePoint(props.or + expand, centerAngle, props.center);
      Alignment align = toAlignment(centerAngle, false);
      if (centerAngle >= 90 && centerAngle <= 270) {
        align = Alignment.centerRight;
      } else {
        align = Alignment.centerLeft;
      }
      textDrawConfig = TextDrawConfig(offset, align: align);
      return;
    }
  }
}

class PieProps {
  final Offset center;
  final num corner;
  final num ir; //内圆半径(<=0时为圆)
  final num or; //外圆最大半径(<=0时为圆)
  final num startAngle; //开始角度
  final num sweepAngle; //扫过的角度(负数为逆时针)
  const PieProps({
    required this.center,
    required this.corner,
    required this.ir,
    required this.or,
    required this.startAngle,
    required this.sweepAngle,
  });

  PieProps clone({
    Offset? center,
    num? corner,
    num? ir,
    num? or,
    num? startAngle,
    num? sweepAngle,
  }) {
    return PieProps(
      center: center ?? this.center,
      corner: corner ?? this.corner,
      ir: ir ?? this.ir,
      or: or ?? this.or,
      startAngle: startAngle ?? this.startAngle,
      sweepAngle: sweepAngle ?? this.sweepAngle,
    );
  }

  @override
  String toString() {
    return 'ir:${ir.toStringAsFixed(2)} or:${or.toStringAsFixed(2)} '
        'SA:${startAngle.toStringAsFixed(2)} '
        'EA:${(startAngle + sweepAngle).toStringAsFixed(2)} '
        'SWEEP:${sweepAngle.toStringAsFixed(2)}';
  }

  double get endAngle => (startAngle + sweepAngle).toDouble();
}
