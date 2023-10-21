import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/tree/tree_view.dart';

class TreeSeries extends RectSeries {
  TreeData data;
  TreeLayout layout;

  ///描述根节点的位置
  List<SNumber> center;
  bool rootInCenter;
  SelectedMode selectedMode;

  ///这个包含了大小等相关信息
  Fun2<TreeData, ChartSymbol>? symbolFun;
  Fun2<TreeData, LabelStyle>? labelStyleFun;
  Fun3<TreeData, TreeData, LineStyle>? linkStyleFun;

  TreeSeries(
    this.data,
    this.layout, {
    this.rootInCenter = true,
    this.center = const [SNumber.number(0), SNumber.percent(50)],
    this.selectedMode = SelectedMode.single,
    this.symbolFun,
    this.linkStyleFun,
    this.labelStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return TreeView(this);
  }

  ChartSymbol getSymbol(Context context, TreeData node) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(node);
    }
    return CircleSymbol(radius: 8, itemStyle: context.option.theme.getAreaStyle(node.groupIndex).convert(node.status));
  }

  LineStyle getLinkStyle(Context context, TreeData source, TreeData target) {
    var fun = linkStyleFun;
    if (fun != null) {
      return fun.call(source, target);
    }
    return LineStyle.normal;
  }

  LabelStyle getLabelStyle(Context context, TreeData source) {
    return labelStyleFun?.call(source) ?? LabelStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    int c = 0;
    List<TreeData> dl = [data];
    List<TreeData> next = [];
    while (dl.isNotEmpty) {
      each(dl, (p0, p1) {
        p0.styleIndex = c;
        c++;
      });
      next.addAll(dl);
      dl = next;
    }
    return c;
  }

  @override
  SeriesType get seriesType => SeriesType.tree;
}
