import '../../component/index.dart';
import '../../functions.dart';
import '../../model/index.dart';
import '../../utils/index.dart';
import '../index.dart';

///该 Series数据是只有一种类型
abstract class ChartListSeries<T extends RenderData> extends ChartSeries {
  List<T> data;

  Fun2<T, AreaStyle>? itemStyleFun;
  Fun2<T, LineStyle>? borderStyleFun;

  LabelStyle? labelStyle;
  Fun2<T, LabelStyle>? labelStyleFun;
  Fun2<T, LineStyle>? labelLineStyleFun;
  Fun2<T, DynamicText>? labelFormatFun;

  ChartListSeries(
    this.data, {
    this.itemStyleFun,
    this.borderStyleFun,
    this.labelStyle,
    this.labelStyleFun,
    this.labelFormatFun,
    this.labelLineStyleFun,
    super.coordType,
    super.gridIndex,
    super.calendarIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.animation,
    super.backgroundColor,
    super.tooltip,
    super.clip,
    super.id,
    super.name,
    super.useSingleLayer,
  });

  AreaStyle getItemStyle(Context context, T data) {
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
    if (labelStyle != null) {
      return labelStyle!;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.label.text;
      if (name.isEmpty) {
        return;
      }
      list.add(LegendItem(name, CircleSymbol()..itemStyle = AreaStyle(color: item.pickColor()), seriesId: id));
    });
    return list;
  }

  DynamicText formatData(Context context, T data) {
    var fun = labelFormatFun;
    if (fun != null) {
      return fun.call(data);
    }
    return DynamicText.empty;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }

  @override
  void dispose() {
    data = [];
    itemStyleFun = null;
    borderStyleFun = null;
    labelStyle = null;
    labelLineStyleFun = null;
    labelFormatFun = null;
    super.dispose();
  }
}
