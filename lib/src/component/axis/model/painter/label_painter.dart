import 'package:e_chart/e_chart.dart';

class LabelPainter extends Disposable {
  final int originIndex;
  final int index;
  final int maxIndex;
  final TextDraw textConfig;
  List<LabelPainter> minorLabel;

  LabelPainter(
    this.originIndex,
    this.index,
    this.maxIndex,
    this.textConfig, [
    this.minorLabel = const [],
  ]);

  @override
  void dispose() {
    super.dispose();
    textConfig.dispose();
    each(minorLabel, (p0, p1) {
      p0.dispose();
    });
    minorLabel = [];
  }
}
