import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'tooltip_theme.dart' as tp;

///全局的主题配置
class ChartTheme extends ChartNotifier2 {
  ///该列表必须至少有一个
  List<Color> _colors = const [
    Color(0xFF63B0F2),
    Color(0xFF07F29C),
    Color(0xFF7F6CC4),
    Color(0xFF4BA47E),
    Color(0xFFF25C05),
    Color(0xFFF3BA17),
    Color(0xFFF36261),
  ];

  ChartTheme();

  List<Color> get colors => _colors;
  Map<int, AreaStyle> _areaStyleMap = {};

  set colors(List<Color> colors) {
    _areaStyleMap = {};
    _colors = List.from(colors, growable: false);
  }

  AreaStyle getAreaStyle(int index) {
    var style = _areaStyleMap[index];
    if (style != null) {
      return style;
    }
    style = AreaStyle(color: getColor(index));
    _areaStyleMap[index] = style;
    return style;
  }

  Color getColor(int index) {
    return colors[index % colors.length];
  }

  Color backgroundColor = const Color(0xFFFDFDFD);

  LabelTheme title = LabelTheme.of(const Color(0xFF464646), 15);
  LabelTheme subTitle = LabelTheme.of(const Color(0xFF464646), 13);
  LabelTheme mark = LabelTheme.of(const Color(0xFFEEEEEE), 13);
  LabelTheme legend = LabelTheme.of(const Color(0xFF333333), 15);

  final LabelTheme _labelStyle = LabelTheme.of(const Color(0xDD000000), 13);
  bool showLabel = true;

  LabelStyle? getLabelStyle() {
    if (!showLabel) {
      return null;
    }
    return _labelStyle.getStyle();
  }

  BorderTheme border = BorderTheme.any(color: const Color(0xFFCCCCCC), width: 1);

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
  HexbinTheme hexbinTheme = HexbinTheme();
  PackTheme packTheme = PackTheme();

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
