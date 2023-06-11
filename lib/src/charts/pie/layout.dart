import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../../animation/tween/double_tween.dart';
import '../../core/context.dart';
import '../../core/layout.dart';
import '../../ext/offset_ext.dart';
import '../../model/dynamic_text.dart';
import '../../model/enums/circle_align.dart';
import '../../model/group_data.dart';
import '../../model/string_number.dart';
import '../../model/text_position.dart';
import '../../shape/arc.dart';
import '../../style/label.dart';
import '../../utils/align_util.dart';
import 'pie_series.dart';
import 'pie_tween.dart';

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

  late Context context;
  Offset center = Offset.zero;
  late PieSeries series;

  void doLayout(Context context, PieSeries series, List<ItemData> list, num width, num height) {
    this.context = context;
    this.series = series;
    this.width = width;
    this.height = height;
    preHandleRadius();
    _nodeList = preHandleData(list);
    _layoutInner(nodeList);
  }

  void preHandleRadius() {
    center = _computeCenterPoint(series.center);
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
      nodeList.add(PieNode.fromPieData(data, series, minRadius, maxRadius, series.angleGap));
      maxData = max([data.value, maxData]);
      minData = min([data.value, minData]);
      allData += data.value;
    });
    if (allData == 0) {
      allData = 1;
    }
    return nodeList;
  }

  void _layoutInner(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    if (series.roseType == RoseType.normal) {
      _layoutForNormal(nodeList);
    } else {
      _layoutForNightingale(nodeList);
    }
  }

  List<PieNode> get nodeList => _nodeList;

  //普通饼图
  void _layoutForNormal(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * series.angleGap.abs();
    num remainAngle = 360 - gapAllAngle;
    num startAngle = series.offsetAngle;
    int direction = series.clockWise ? 1 : -1;
    remainAngle *= direction;
    num angleGap = series.angleGap * direction;

    each(nodeList, (node, i) {
      var pieData = node.data;
      num sw = remainAngle * pieData.value / allData;
      node.props = PieProps(ir: minRadius, or: maxRadius, startAngle: startAngle, sweepAngle: sw, corner: series.corner);
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
    num remainAngle = 360 - gapAllAngle;
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
        node.props = PieProps(ir: minRadius, corner: series.corner, or: or, startAngle: startAngle, sweepAngle: sweepAngle);
        startAngle += sweepAngle + angleGap;
        debugPrint('${pieData.label} ${node.props}');
      });
    }
  }

  Offset _computeCenterPoint(List<SNumber> center) {
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    return Offset(x, y);
  }

  PieNode? _hoverNode;

  void handleHover(Offset offset) {
    if (nodeList.isEmpty) {
      return;
    }
    PieNode? clickNode = findNode(offset);
    if (clickNode == null) {
      logPrint('无法找到点击节点');
    }

    bool hasSame = clickNode == _hoverNode;
    if (hasSame) {
      logPrint('相同节点无需处理');
      return;
    }
    _hoverNode = clickNode;
    Map<PieNode, PieProps> oldPropsMap = {};
    each(nodeList, (node, p1) {
      node.select = node == clickNode;
      oldPropsMap[node] = node.props;
    });

    ///二次布局
    _layoutInner(nodeList);
    Map<PieNode, PieProps> propsMap = {};
    each(nodeList, (node, p1) {
      if (node == clickNode) {
        PieProps p;
        if(series.scaleExtend.percent){
          var or=node.props.or*(1+series.scaleExtend.percentRatio());
          p = node.props.clone(or: or);
        }else{
          p = node.props.clone(or: node.props.or +series.scaleExtend.number);
        }

        propsMap[node] = p;
        node.select = true;
      } else {
        propsMap[node] = node.props;
        node.select = false;
      }
    });
    PieNode firstNode = nodeList[0];
    PieTween tween = PieTween(firstNode.props, firstNode.props);
    ChartDoubleTween doubleTween = ChartDoubleTween(0, 1, duration: const Duration(milliseconds: 150));
    doubleTween.addListener(() {
      for (var node in nodeList) {
        tween.changeValue(oldPropsMap[node]!, propsMap[node]!);
        node.props = tween.safeGetValue(doubleTween.value);
      }
      notifyLayoutUpdate();
    });
    doubleTween.start(context);
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
  final DynamicText? label;
  final LabelStyle? labelStyle;
  final num anglePad;

  bool select = false;

  PieProps props = const PieProps(ir: 0, or: 0, startAngle: 0, sweepAngle: 0, corner: 0);

  PieNode(this.data, this.label, this.labelStyle, this.anglePad);

  static PieNode fromPieData(ItemData data, PieSeries series, num minRadius, num maxRadius, num anglePad) {
    return PieNode(data, data.label, series.labelStyleFun?.call(data, null), anglePad);
  }

  Path toPath() {
    Arc arc = Arc(
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
  TextDrawConfig? computeTextPosition(PieSeries series) {
    if (label == null || label!.isEmpty || labelStyle == null || !labelStyle!.show) {
      return null;
    }

    if (series.labelAlign == CircleAlign.center) {
      return TextDrawConfig(Offset.zero, align: Alignment.center);
    }

    if (series.labelAlign == CircleAlign.inside) {
      double radius = (props.ir + props.or) / 2;
      double angle = props.startAngle + props.sweepAngle / 2;
      Offset offset = circlePoint(radius, angle);
      return TextDrawConfig(offset, align: Alignment.center);
    }

    if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle!.guideLine.length;
      double centerAngle = props.startAngle + props.sweepAngle / 2;

      centerAngle %= 360;
      if (centerAngle < 0) {
        centerAngle += 360;
      }

      Offset offset = circlePoint(props.or + expand, centerAngle);
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
  final num corner;
  final num ir; //内圆半径(<=0时为圆)
  final num or; //外圆最大半径(<=0时为圆)
  final num startAngle; //开始角度
  final num sweepAngle; //扫过的角度(负数为逆时针)
  const PieProps({
    required this.corner,
    required this.ir,
    required this.or,
    required this.startAngle,
    required this.sweepAngle,
  });

  PieProps clone({
    num? corner,
    num? ir,
    num? or,
    num? startAngle,
    num? sweepAngle,
  }) {
    return PieProps(
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
