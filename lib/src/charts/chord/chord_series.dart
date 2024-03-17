import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/chord/chord_data_helper.dart';
import 'package:e_chart/src/charts/chord/chord_view.dart';

class ChordSeries extends RectSeries {
  List<ChordLink> data;
  List<SNumber> center;
  num startAngle;
  num padAngle;
  SNumber radius;
  SNumber chordWidth;
  SNumber chordGap;

  bool direction;
  Fun3<ChordData, ChordData, int>? sortFun;
  Fun3<ChordData, ChordData, int>? linkSortFun;

  Fun2<ChordData, AreaStyle>? itemStyleFun;
  Fun2<ChordData, LineStyle>? borderStyleFun;

  Fun2<ChordLink, LineStyle>? linkBorderStyleFun;
  Fun2<ChordLink, AreaStyle>? linkItemStyleFun;

  LabelStyle? labelStyle;
  Fun2<ChordData, LabelStyle>? labelStyleFun;
  Fun2<ChordData, LineStyle>? labelLineStyleFun;
  Fun2<ChordData, DynamicText>? labelFormatFun;

  ChordSeries(
    this.data, {
    this.direction = false,
    this.center = const [SNumber.percent(50)],
    this.radius = const SNumber.percent(95),
    this.chordWidth = const SNumber.number(16),
    this.chordGap = SNumber.zero,
    this.startAngle = 0,
    this.padAngle = 0,
    this.sortFun,
    this.linkSortFun,
    this.borderStyleFun,
    this.itemStyleFun,
    this.labelFormatFun,
    this.labelLineStyleFun,
    this.labelStyle,
    this.labelStyleFun,
    this.linkBorderStyleFun,
    this.linkItemStyleFun,
    super.id,
    super.name,
    super.width,
    super.height,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.backgroundColor,
    super.animation,
    super.coordType,
    super.gridIndex,
    super.calendarIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.tooltip,
    super.useSingleLayer,
    super.clip,
  });

  ChordDataHelper? _dataHelper;

  ChordDataHelper dataHelper() {
    _dataHelper ??= ChordDataHelper(data, direction, sortFun: sortFun, linkSortFun: linkSortFun);
    return _dataHelper!;
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(dataHelper().dataList, (item, i) {
      var name = item.label.text;
      if (name.isEmpty) {
        return;
      }
      list.add(LegendItem(name, CircleSymbol()..itemStyle = AreaStyle(color: item.pickColor()), seriesId: id));
    });
    return list;
  }

  DynamicText formatData(Context context, ChordData data) {
    var fun = labelFormatFun;
    if (fun != null) {
      return fun.call(data);
    }
    return DynamicText.empty;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(dataHelper().dataList, (p0, p1) {
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

  AreaStyle getItemStyle(Context context, ChordData data) {
    var fun = itemStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.getAreaStyle(data.styleIndex).convert(data.status);
  }

  LineStyle getBorderStyle(Context context, ChordData data) {
    var fun = borderStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, ChordData data) {
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

  AreaStyle getLinkItemStyle(Context context, ChordLink data) {
    var fun = linkItemStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.getAreaStyle(data.styleIndex).convert(data.status);
  }

  LineStyle getLinkBorderStyle(Context context, ChordLink data) {
    var fun = linkBorderStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return LineStyle.empty;
  }

  @override
  SeriesType get seriesType => SeriesType.chord;

  @override
  ChartView? toView(Context context) => ChordView(context,this);
}
