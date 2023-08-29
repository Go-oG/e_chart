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
  bool smooth;
  Fun4<BaseItemData, int, Set<ViewState>, AreaStyle?>? areaStyleFun;

  Fun4<BaseItemData, int, Set<ViewState>, LineStyle?>? borderStyleFun;

  Fun7<BaseItemData, int, Set<ViewState>, BaseItemData, int, Set<ViewState>, AreaStyle>? linkStyleFun;

  SankeySeries({
    required this.data,
    this.nodeWidth = 32,
    this.gap = 8,
    this.iterationCount = 6,
    this.align = const JustifyAlign(),
    this.direction = Direction.horizontal,
    this.nodeSort,
    this.linkSort,
    this.areaStyleFun,
    this.linkStyleFun,
    this.smooth = true,
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
  }) : super(gridIndex: -1, polarIndex: -1, radarIndex: -1, calendarIndex: -1, parallelIndex: -1);

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

class SankeyLinkData extends ItemData {
  final ItemData src;
  final ItemData target;

  SankeyLinkData(this.src, this.target, super.value, {super.label, super.id});

  @override
  int get hashCode {
    return Object.hash(src, target);
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyLinkData && other.src == src && other.target == target;
  }
}
