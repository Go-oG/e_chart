import 'dart:ui';

import '../index.dart';
import 'chart/line_theme.dart';

///全局的主题配置
class ChartTheme {
  ///该列表必须至少有一个
  List<Color> colors = [
    const Color(0xFF5C6BC0),
    const Color(0xFFF98000),
    const Color(0xFFee6666),
    const Color.fromARGB(255, 105, 189, 67),
    const Color(0xFF9a60b4),
    const Color(0xFFfac858),
    const Color(0xFFea7ccc),
    const Color(0xFF73c0de),
  ];

  Color getColor(int index) {
    return colors[index % colors.length];
  }

  Color backgroundColor = const Color(0xFFFFFFFF);
  Color titleTextColor = const Color(0xFF464646);
  Color titleSubTextColor = const Color(0xFF6E7079);
  Color markTextColor = const Color(0xFFEEEEEE);
  Color borderColor = const Color(0xFFCCCCCC);
  num borderWidth = 0;
  Color legendTextColor = const Color(0xFF333333);

  Color labelTextColor = const Color(0xFFFFFFFF);
  double labelTextSize=13;

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
  HeadMapTheme headMapTheme = HeadMapTheme();
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

  static ChartTheme dark() {
    ChartTheme theme = ChartTheme();
    theme.colors = [];
    theme.backgroundColor = const Color(0xFF121212);

    return theme;
  }
}
