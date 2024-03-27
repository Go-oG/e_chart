import '../core/context.dart';
import '../core/render/render_data.dart';
import '../functions.dart';
import '../model/data.dart';
import '../option/style/index.dart';
import 'index.dart';

///表述为数据类型为 Group-children 图表
abstract class ChartGroupSeries<T extends RenderData, G> extends ChartSeries {
  List<G> data;

  Fun3<T, G, AreaStyle>? itemStyleFun;
  Fun3<T, G, LineStyle>? borderStyleFun;
  LabelStyle? labelStyle;
  Fun3<T, G, LabelStyle>? labelStyleFun;
  Fun3<T, G, LineStyle>? labelLineStyleFun;
  Fun2<T, DynamicText>? labelFormatFun;

  ChartGroupSeries(
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

  AreaStyle getItemStyle(Context context, T data, G parent) {
    var fun = itemStyleFun;
    if (fun != null) {
      return fun.call(data, parent);
    }
    return context.option.theme.getAreaStyle(data.styleIndex).convert(data.status);
  }

  LineStyle getBorderStyle(Context context, T data, G parent) {
    var fun = borderStyleFun;
    if (fun != null) {
      return fun.call(data, parent);
    }
    return LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, T data, G parent) {
    var fun = labelStyleFun;
    if (fun != null) {
      return fun.call(data, parent);
    }
    if (labelStyle != null) {
      return labelStyle!;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
  }

  DynamicText formatData(Context context, T data) {
    var fun = labelFormatFun;
    if (fun != null) {
      return fun.call(data);
    }
    return DynamicText.empty;
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
