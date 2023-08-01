import 'package:e_chart/e_chart.dart';

///坐标轴样式相关的配置
class AxisStyle {
  bool show;
  AxisLine axisLine = AxisLine();
  AxisLabel axisLabel = AxisLabel();
  SplitLine splitLine = SplitLine();
  AxisTick axisTick = AxisTick();

  ///坐标轴指示器
  AxisPointer? axisPointer;
  AxisMinorTick? minorTick;
  MinorSplitLine? minorSplitLine;
  SplitArea? splitArea;

  AxisStyle({
    this.show = true,
    AxisLine? line,
    AxisLabel? label,
    AxisTick? tick,
    SplitLine? splitLine,
    this.axisPointer,
    this.minorTick,
    this.minorSplitLine,
    this.splitArea,
  }) {
    if (line != null) {
      axisLine = line;
    }
    if (label != null) {
      axisLabel = label;
    }
    if (tick != null) {
      axisTick = tick;
    }
    if (splitLine != null) {
      this.splitLine = splitLine;
    }
  }

  LineStyle? getAxisLineStyle(int index, int maxIndex, AxisTheme theme) {
    return axisLine.getAxisLineStyle(index, maxIndex, theme);
  }

  LineStyle? getSplitLineStyle(int index, int maxIndex, AxisTheme theme) {
    return splitLine.getSplitLineStyle(index, maxIndex, theme);
  }

  AreaStyle? getSplitAreaStyle(int index, int maxIndex, AxisTheme theme) {
    if (splitArea != null) {
      return splitArea?.getSplitAreaStyle(index, maxIndex, theme);
    }
    return theme.getSplitAreaStyle(index);
  }

  MainTick? getMainTick(int index, int maxIndex, AxisTheme theme) {
    return axisTick.getTick(index, maxIndex, theme);
  }

  MinorTick? getMinorTick(int index, int maxIndex, AxisTheme theme) {
    return minorTick?.getTick(index, maxIndex, theme);
  }

  LabelStyle? getLabelStyle(int index, int maxIndex, AxisTheme theme) {
    return axisLabel.getLabelStyle(index, maxIndex, theme);
  }

  LabelStyle? getMinorLabelStyle(int index, int maxIndex, AxisTheme theme) {
    return axisLabel.getMinorLabelStyle(index, maxIndex, theme);
  }
}
