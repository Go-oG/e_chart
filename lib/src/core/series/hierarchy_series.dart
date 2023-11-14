import 'package:e_chart/e_chart.dart';

///具有层次结构的图表(比如树图、旭日图)
abstract class HierarchySeries<T extends BaseTreeData<dynamic, T>> extends RectSeries {
  T data;

  ///填充区域的样式
  Fun2<T, AreaStyle>? itemStyleFun;
  Fun2<T, LineStyle>? borderStyleFun;

  ///文字标签的样式
  Fun2<T, LabelStyle>? labelStyleFun;

  HierarchySeries(
    this.data, {
    this.labelStyleFun,
    this.itemStyleFun,
    this.borderStyleFun,
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
    super.coordType,
    super.calendarIndex,
    super.gridIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
  });

  AreaStyle getAreaStyle(Context context, T data) {
    var fun = itemStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.getAreaStyle(data.styleIndex).convert(data.status);
  }

  LineStyle getBorderStyle(Context context, T data) {
    var fun = borderStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, T data) {
    var fun = labelStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    int c = 0;
    data.each((p0, index, startNode) {
      p0.styleIndex = c;
      c++;
      return false;
    });
    return c;
  }

  @override
  void dispose() {
    super.dispose();
    itemStyleFun = null;
    borderStyleFun = null;
    labelStyleFun = null;
  }
}
