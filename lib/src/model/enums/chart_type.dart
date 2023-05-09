///https://echarts.apache.org/zh/option.html#series-heatmap
class ChartType {
  final String key;
  const ChartType._(this.key);
  static const ChartType line = ChartType._('line');
  static const ChartType bar = ChartType._('bar');
  static const ChartType pie = ChartType._('pie');
  static const ChartType point = ChartType._('point');
  static const ChartType tree = ChartType._('tree');
  static const ChartType radar = ChartType._('radar');
  static const ChartType treeMap = ChartType._('treeMap');
  static const ChartType sunburst = ChartType._('sunburst');
  static const ChartType boxplot = ChartType._('boxplot');
  static const ChartType candlestick = ChartType._('candlestick');
  static const ChartType calendar = ChartType._('calendar');
  static const ChartType heatMap = ChartType._('heatMap');
  static const ChartType map = ChartType._('map');
  static const ChartType parallel = ChartType._('parallel');
  static const ChartType graph = ChartType._('graph');
  static const ChartType sankey = ChartType._('sankey');
  static const ChartType funnel = ChartType._('funnel');
  static const ChartType force = ChartType._('force');
  static const ChartType gauge = ChartType._('gauge');
  static const ChartType pictorialBar = ChartType._('pictorialBar');
  static const ChartType themeRiver = ChartType._('themeRiver');

  @override
  bool operator ==(Object other) {
    return (other is ChartType) && other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}