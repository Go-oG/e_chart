import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

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
  bool fill = true;
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
  bool showSymbol = true;
  Size symbolSize = const Size.square(4);
  ChartSymbol symbol = EmptySymbol();

  bool fill = false;

  ///用于坐标轴相关的
  List<Color> splitColors = [
    const Color(0xFFFFFFFF),
  ];
  List<Color> borderColors = [
    const Color(0xFFFFFFFF),
  ];
  num borderWidth = 1;

  Color getSplitLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (borderColors.isNotEmpty) {
      return borderColors[index % borderColors.length];
    }
    return Colors.black26;
  }

  LineStyle getSplitLineStyle(int index) {
    Color color = getSplitLineColor(index);
    return LineStyle(color: color, width: borderWidth);
  }

  Color getSplitAreaColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (splitColors.isNotEmpty) {
      return splitColors[index % splitColors.length];
    }
    return Colors.white;
  }

  AreaStyle getSplitAreaStyle(int index) {
    Color color = getSplitAreaColor(index);
    return AreaStyle(color: color);
  }
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
  Color? fillColor;
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
  LabelStyle labelStyle = const LabelStyle();
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
  num axisLineWidth = 1;

  MainTick? tick = MainTick();
  MinorTick? minorTick;

  bool showLabel = true;
  Color labelColor = const Color(0xFF6E7079);
  num labelSize=15;

  bool showMinorLabel = false;
  Color minorLabelColor = const Color(0xFF6E7079);
  num minorLabelSize=13;





  bool showSplitLine = true;
  num splitLineWidth = 1;
  List<Color> splitLineColors = [
    const Color(0xFFE0E6F1),
  ];

  bool showSplitArea = false;
  List<Color> splitAreaColors = [
    const Color.fromRGBO(250, 250, 250, 0.2),
    const Color.fromRGBO(210, 219, 238, 0.2),
  ];

  MainTick? getMainTick() {
    if (tick == null || !tick!.show) {
      return null;
    }
    return tick;
  }

  MinorTick? getMinorTick() {
    if (minorTick == null || !minorTick!.show) {
      return null;
    }
    return minorTick;
  }

  Color? getSplitLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showSplitLine) {
      return null;
    }
    if (splitLineColors.isNotEmpty) {
      return splitLineColors[index % splitLineColors.length];
    }
    return axisLineColor;
  }

  LineStyle? getSplitLineStyle(int index) {
    Color? color = getSplitLineColor(index);
    if (color != null) {
      return LineStyle(color: color, width: splitLineWidth);
    }
    return null;
  }

  Color? getSplitAreaColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showSplitArea) {
      return null;
    }
    if (splitAreaColors.isNotEmpty) {
      return splitAreaColors[index % splitAreaColors.length];
    }
    return Colors.white;
  }

  AreaStyle? getSplitAreaStyle(int index) {
    Color? color = getSplitAreaColor(index);
    if (color != null) {
      return AreaStyle(color: color);
    }
    return null;
  }

  Color? getAxisLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showAxisLine) {
      return null;
    }
    return axisLineColor;
  }

  LineStyle? getAxisLineStyle(int index) {
    Color? color = getAxisLineColor(index);
    if (color != null) {
      return LineStyle(color: color, width: axisLineWidth);
    }
    return null;
  }
}
