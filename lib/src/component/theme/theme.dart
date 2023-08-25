import 'package:e_chart/src/component/theme/chart/hexbin_theme.dart';
import 'package:e_chart/src/component/theme/chart/pack_theme.dart';
import 'package:flutter/material.dart';
import 'tooltip_theme.dart' as tp;
import '../index.dart';
import 'chart/line_theme.dart';

///全局的主题配置
class ChartTheme {
  ///该列表必须至少有一个
  List<Color> colors = const [
    Color(0xFF63B0F2),
    Color(0xFF07F29C),
    Color(0xFF7F6CC4),
    Color(0xFF4BA47E),
    Color(0xFFF25C05),
    Color(0xFFF3BA17),
    Color(0xFFF36261),
  ];

  Color getColor(int index) {
    return colors[index % colors.length];
  }

  Color backgroundColor = const Color(0xFFFDFDFD);
  Color titleTextColor = const Color(0xFF464646);
  Color titleSubTextColor = const Color(0xFF6E7079);
  Color markTextColor = const Color(0xFFEEEEEE);
  Color borderColor = const Color(0xFFCCCCCC);
  num borderWidth = 0;
  Color legendTextColor = const Color(0xFF333333);

  Color labelTextColor = Colors.black87;
  double labelTextSize = 13;

  ///通用组件主题
  tp.TooltipTheme tooltipTheme = tp.TooltipTheme();
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
  HexbinTheme hexbinTheme=HexbinTheme();
  PackTheme packTheme=PackTheme();

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
