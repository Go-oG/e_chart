import '../../style/line_style.dart';

///坐标轴在grid区域中的分隔线
class SplitLine {
  final bool show;

  final int interval;

  final LineStyle style;

  const SplitLine({
    this.show = false,
    this.interval = -1,
    this.style = const LineStyle(),
  });
}

class MinorSplitLine {
  final bool show;

  final LineStyle style;

 const  MinorSplitLine({
    this.show = false,
    this.style = const LineStyle(),
  });
}
