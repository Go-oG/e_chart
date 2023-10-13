class SeriesType {
  static const SeriesType bar = SeriesType("bar", 1);
  static const SeriesType line = SeriesType("line", 99);
  static const SeriesType boxplot = SeriesType("boxplot", 1);
  static const SeriesType candlestick = SeriesType("candlestick", 1);
  static const SeriesType calendar = SeriesType("calendar", 1);
  static const SeriesType funnel = SeriesType("funnel", 1);
  static const SeriesType heatmap = SeriesType("heatmap", 1);
  static const SeriesType parallel = SeriesType("parallel", 1);
  static const SeriesType pie = SeriesType("pie", 1);
  static const SeriesType point = SeriesType("point", 100);
  static const SeriesType radar = SeriesType("radar", 1);
  static const SeriesType graph = SeriesType("graph", 1);
  static const SeriesType hexbin = SeriesType("hexbin", 1);
  static const SeriesType pack = SeriesType("pack", 1);
  static const SeriesType sankey = SeriesType("sankey", 1);
  static const SeriesType sunburst = SeriesType("sunburst", 1);
  static const SeriesType themeRiver = SeriesType("themeriver", 1);
  static const SeriesType tree = SeriesType("tree", 1);
  static const SeriesType treemap = SeriesType("treemap", 1);
  static const SeriesType circle = SeriesType("circle", 1);
  static const SeriesType delaunay = SeriesType("delaunay", 1);

  final String type;

  ///当前图表的优先级(用于当多个Series存在同一个坐标系时确定其绘制先后顺序，数值越大的越后绘制)
  final int priority;

  const SeriesType(this.type, this.priority);

  @override
  int get hashCode {
    return type.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesType && other.type == type;
  }

  @override
  String toString() {
    return '$type $priority';
  }
}
