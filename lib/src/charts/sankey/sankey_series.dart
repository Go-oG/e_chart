import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/sankey/sankey_view.dart';

class SankeySeries extends RectSeries {
  SankeyData data;
  double nodeWidth;
  double gap;
  int iterationCount;
  SankeyAlign align;
  NodeSort? nodeSort;
  LinkSort? linkSort;
  Direction direction;
  Fun2<ItemData, AreaStyle> nodeStyle;
  Fun3<ItemData, ItemData, AreaStyle>? linkStyleFun;

  SankeySeries({
    required this.data,
    this.nodeWidth = 16,
    this.gap = 8,
    this.iterationCount = 6,
    this.align = const JustifyAlign(),
    this.direction = Direction.horizontal,
    this.nodeSort,
    this.linkSort,
    required this.nodeStyle,
    this.linkStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.animation,
    super.clip,
    super.z,
  }) : super(
          gridIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
          parallelIndex: -1
        );
  @override
  ChartView? toView() {
    return SankeyView(this);
  }
}

class SankeyData {
  final List<ItemData> data;
  final List<SankeyLinkData> links;

  SankeyData(this.data, this.links);
}

class SankeyLinkData {
  ItemData src;
  ItemData target;
  double value;
  DynamicText? label;

  SankeyLinkData(this.src, this.target, this.value, {this.label});

  @override
  int get hashCode {
    return Object.hash(src, target);
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyLinkData && other.src == src && other.target == target;
  }
}
