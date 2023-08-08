import 'package:e_chart/e_chart.dart';

///高亮行为
class HighlightAction extends ChartAction {
  final List<int> seriesIndex;
  final List<String> seriesId;

  final List<int> dataIndex;
  final List<String> dataId;

  HighlightAction({
    this.seriesIndex = const [],
    this.seriesId = const [],
    this.dataIndex = const [],
    this.dataId = const [],
    super.fromUser,
  });
}
