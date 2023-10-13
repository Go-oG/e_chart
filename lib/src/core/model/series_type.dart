class SeriesType {
  static const SeriesType bar = SeriesType("bar", 0);
  static const SeriesType line = SeriesType("line", 99);
  static const SeriesType boxplot = SeriesType("boxplot", 0);
  static const SeriesType candlestick = SeriesType("candlestick", 0);
  static const SeriesType calendar = SeriesType("calendar", 0);
  static const SeriesType funnel = SeriesType("funnel", 0);
  static const SeriesType heatmap = SeriesType("heatmap", 0);
  static const SeriesType parallel = SeriesType("parallel", 0);
  static const SeriesType pie = SeriesType("pie", 0);
  static const SeriesType point = SeriesType("point", 100);
  static const SeriesType radar = SeriesType("radar", 0);
  static const SeriesType graph = SeriesType("graph", 0);
  static const SeriesType hexbin = SeriesType("hexbin", 0);
  static const SeriesType pack = SeriesType("pack", 0);
  static const SeriesType sankey = SeriesType("sankey", 0);
  static const SeriesType sunburst = SeriesType("sunburst", 0);
  static const SeriesType themeRiver = SeriesType("themeriver", 0);
  static const SeriesType tree = SeriesType("tree", 0);
  static const SeriesType treemap = SeriesType("treemap", 0);
  static const SeriesType circle = SeriesType("circle", 0);
  static const SeriesType delaunay = SeriesType("delaunay", 0);

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
