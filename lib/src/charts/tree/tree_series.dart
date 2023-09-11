
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/tree/tree_view.dart';

class TreeSeries extends RectSeries {
  TreeData data;
  TreeLayout layout;
  SelectedMode selectedMode;
  Fun2<TreeLayoutNode, ChartSymbol> symbolFun;
  Fun2<TreeLayoutNode, LabelStyle>? labelStyleFun;
  Fun3<TreeLayoutNode, TreeLayoutNode, LineStyle> linkStyleFun;

  TreeSeries(
    this.data,
    this.layout, {
    this.selectedMode = SelectedMode.single,
    required this.symbolFun,
    required this.linkStyleFun,
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
    super.z,
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return TreeView(this);
  }

  ChartSymbol getSymbol(Context context, TreeLayoutNode node) {
    return symbolFun.call(node);
  }

  LineStyle getLinkStyle(Context context, TreeLayoutNode source,TreeLayoutNode target) {
    return linkStyleFun.call(source,target);
  }

}
