//盒须图
import 'package:e_chart/e_chart.dart';

class BoxplotSeries extends ChartSeries {
  List<BoxplotGroup> data;
  Fun3<BoxplotData, BoxplotGroup, LineStyle>? borderStyleFun;
  Fun3<BoxplotData, BoxplotGroup, AreaStyle?>? areaStyleFun;
  Direction direction;

  SNumber boxMinWidth;
  SNumber boxMaxWidth;
  SNumber? boxWidth;

  BoxplotSeries({
    required this.data,
    this.direction = Direction.vertical,
    this.boxMinWidth = const SNumber.number(24),
    this.boxMaxWidth = const SNumber.number(48),
    this.boxWidth,
    this.borderStyleFun,
    this.areaStyleFun,
    super.animation,
    super.polarIndex,
    super.gridIndex,
    super.tooltip,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.z,
    super.clip,
  }) : super(coordSystem: CoordSystem.grid, calendarIndex: -1, parallelIndex: -1, radarIndex: -1);


  AreaStyle? getAreaStyle(Context context, BoxplotData data, BoxplotGroup group, int groupIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group);
    }
    var chartTheme = context.option.theme;
    return AreaStyle(color: chartTheme.getColor(groupIndex)).convert(status);
  }

  LineStyle getBorderStyle(Context context,BoxplotData data, BoxplotGroup group, int groupIndex, [Set<ViewState>? status]) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, group);
    }
    var theme = context.option.theme.boxplotTheme;
    return theme.getBorderStyle(context.option.theme,groupIndex).convert(status);
  }

}

class BoxplotGroup {
  List<BoxplotData> data;
  int xAxisIndex;
  int yAxisIndex;

  BoxplotGroup(this.data, {this.xAxisIndex = 0, this.yAxisIndex = 0});
}

class BoxplotData {
  late final String id;
  DynamicData x;
  DynamicData max;
  DynamicData upAve4;
  DynamicData middle;
  DynamicData downAve4;
  DynamicData min;
  DynamicText? label;

  BoxplotData({
    required this.x,
    required this.max,
    required this.upAve4,
    required this.middle,
    required this.downAve4,
    required this.min,
    this.label,
    String? id,
  }) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
  }
}
