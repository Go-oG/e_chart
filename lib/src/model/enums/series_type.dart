class SeriesType {
  static const SeriesType bar=SeriesType("bar");
  static const SeriesType line=SeriesType("line");
  static const SeriesType boxplot=SeriesType("boxplot");
  static const SeriesType candlestick=SeriesType("candlestick");
  static const SeriesType funnel=SeriesType("funnel");
  static const SeriesType heatmap=SeriesType("heatmap");
  static const SeriesType parallel=SeriesType("parallel");
  static const SeriesType pie=SeriesType("pie");
  static const SeriesType point=SeriesType("point");
  static const SeriesType radar=SeriesType("radar");
  static const SeriesType graph=SeriesType("graph");
  static const SeriesType hexbin=SeriesType("hexbin");
  static const SeriesType pack=SeriesType("pack");
  static const SeriesType sankey=SeriesType("sankey");
  static const SeriesType sunburst=SeriesType("sunburst");
  static const SeriesType themeriver=SeriesType("themeriver");
  static const SeriesType tree=SeriesType("tree");
  static const SeriesType treemap=SeriesType("treemap");

  final String type;

  const SeriesType(this.type);

  @override
  int get hashCode {
    return type.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesType && other.type == type;
  }
}
