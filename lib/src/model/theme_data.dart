import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///全局的主题配置
class ChartTheme {
  ///该列表必须至少有一个
  List<Color> colors = [
    const Color(0xFF5470c6),
    const Color(0xFF91cc75),
    const Color(0xFFfac858),
    const Color(0xFFee6666),
    const Color(0xFF73c0de),
    const Color(0xFF3ba272),
    const Color(0xFFfc8452),
    const Color(0xFF9a60b4),
    const Color(0xFFea7ccc),
  ];
  Color backgroundColor = const Color(0xFFFFFFFF);
  Color titleTextColor = const Color(0xFF464646);
  Color titleSubTextColor = const Color(0xFF6E7079);
  Color markTextColor = const Color(0xFFEEEEEE);
  Color borderColor = const Color(0xFFCCCCCC);
  num borderWidth = 0;
  Color legendTextColor = const Color(0xFF333333);

  ///通用组件主题
  TooltipTheme tooltipTheme = TooltipTheme();
  MarkPointTheme markPointTheme = MarkPointTheme();
  VisualMapTheme visualMapTheme = VisualMapTheme();

  ///坐标轴主题
  AxisTheme normalAxisTheme = AxisTheme();
  AxisTheme categoryAxisTheme = AxisTheme();
  AxisTheme valueAxisTheme = AxisTheme();
  AxisTheme logAxisTheme = AxisTheme();
  AxisTheme timeAxisTheme = AxisTheme();

  ///相关图表主题
  KLineTheme kLineTheme = KLineTheme();
  LineTheme lineTheme = LineTheme();
  RadarTheme radarTheme = RadarTheme();
  BarTheme barTheme = BarTheme();
  PieTheme pieTheme = PieTheme();
  PointTheme pointTheme = PointTheme();
  BoxplotTheme boxplotTheme = BoxplotTheme();
  ParallelTheme parallelTheme = ParallelTheme();
  SankeyTheme sankeyTheme = SankeyTheme();
  FunnelTheme funnelTheme = FunnelTheme();
  GaugeTheme gaugeTheme = GaugeTheme();
  CandlestickTheme candlestickTheme = CandlestickTheme();
  HeadMapTheme mapTheme = HeadMapTheme();
  GraphTheme graphTheme = GraphTheme();

  final Map<String, dynamic> _themeMap = {};

  T? getTheme<T>(String key) {
    return _themeMap[key];
  }

  void registerTheme(String key, dynamic theme) {
    _themeMap[key] = theme;
  }

  void removeTheme(String key) {
    _themeMap.remove(key);
  }

  void clearTheme() {
    _themeMap.clear();
  }
}

///其它通用配置
class TooltipTheme {
  AreaStyle style = const AreaStyle();
}

class MarkPointTheme {
  LabelStyle labelStyle = const LabelStyle();
  LabelStyle labelHoverStyle = const LabelStyle();
}

///视觉映射主题
class VisualMapTheme {
  List<Color> colors = [
    const Color(0xFFbf444c),
    const Color(0xFFd88273),
    const Color(0xFFf6efa6),
  ];
}

///K线图主题
class KLineTheme {
  Color upColor = const Color(0xFFEB5454);
  Color upBorderColor = const Color(0xFFEB5454);
  Color downColor = const Color(0xFF47b262);
  Color downBorderColor = const Color(0xFF47b262);
  num borderWidth = 1;
}

///折线图主题
class LineTheme {
  num lineWidth = 2;
  num symbolSize = 4;
  ChartSymbol symbol = CircleSymbol();
  bool smooth = false;
}

///Radar主题
class RadarTheme {
  num lineWidth = 2;
  num symbolSize = 4;
  ChartSymbol symbol = EmptySymbol();
  List<Color> splitColors = [
    const Color(0xFFFFFFFF),
  ];
  List<Color> borderColors = [
    const Color(0xFFFFFFFF),
  ];
  num borderWidth = 1;
}

class BarTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class PieTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class PointTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class BoxplotTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class ParallelTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class SankeyTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class FunnelTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
  LabelStyle labelStyle = LabelStyle();
  List<Color> colors = [
    const Color(0xFF5470c6),
    const Color(0xFF91cc75),
    const Color(0xFFfac858),
    const Color(0xFFee6666),
    const Color(0xFF73c0de),
    const Color(0xFF3ba272),
    const Color(0xFFfc8452),
    const Color(0xFF9a60b4),
    const Color(0xFFea7ccc),
  ];
}

class GaugeTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class CandlestickTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
}

class GraphTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
  num lineWidth = 1;
  Color lineColor = const Color(0xFFAAAAAA);
  bool lineSmooth = false;
  ChartSymbol symbol = CircleSymbol.normal();
  List<Color> colors = [
    const Color(0xFF5470c6),
    const Color(0xFF91cc75),
    const Color(0xFFfac858),
    const Color(0xFFee6666),
    const Color(0xFF73c0de),
    const Color(0xFF3ba272),
    const Color(0xFFfc8452),
    const Color(0xFF9a60b4),
    const Color(0xFFea7ccc),
  ];
  Color labelColor = const Color(0xFFEEEEEE);
}

class HeadMapTheme {
  AreaStyle areaStyle = const AreaStyle(color: Color(0xFFEEEEEE), border: LineStyle(color: Color(0xFF444444), width: 0.5));
  LabelStyle labelStyle = const LabelStyle();
}

///坐标轴主题
class AxisTheme {
  bool showAxisLine = true;
  Color axisLineColor = const Color(0xFF6E7079);
  bool showTick = true;
  Color tickColor = const Color(0xFF6E7079);
  bool showLabel = true;
  Color labelColor = const Color(0xFF6E7079);
  bool showSplitLine = true;
  List<Color> splitLineColors = [
    const Color(0xFFE0E6F1),
  ];
  bool showSplitArea = false;
  List<Color> splitAreaColors = [
    const Color.fromRGBO(250, 250, 250, 0.2),
    const Color.fromRGBO(210, 219, 238, 0.2),
  ];
}
