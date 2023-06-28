import '../../style/line_style.dart';

///坐标轴在grid区域中的分隔线
class SplitLine {
  bool show;
  int interval;
  LineStyle style;
  SplitLine({
    this.show = false,
    this.interval = -1,
    this.style = const LineStyle(),
  });
}

class MinorSplitLine {
  bool show;
  LineStyle style;

  MinorSplitLine({
    this.show = false,
    this.style = const LineStyle(),
  });
}
