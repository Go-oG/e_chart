import 'package:e_chart/e_chart.dart';

class ToggleSelectAction extends ChartAction{
  final List<int> seriesIndex;
  final List<String> seriesId;

  final List<int> dataIndex;
  final List<String> dataId;

  ToggleSelectAction({
    this.seriesIndex = const [],
    this.seriesId = const [],
    this.dataIndex = const [],
    this.dataId = const [],
    super.fromUser,
  });
}