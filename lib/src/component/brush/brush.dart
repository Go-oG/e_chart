import 'package:e_chart/e_chart.dart';

///框选配置
class Brush extends ChartNotifier<Command> {
  static final Command clearCommand = Command(2, runAnimation: false);
  late final String id;
  bool enable = false;
  BrushType mode;
  SelectedMode selectedMode;
  bool supportMulti;

  ///supportMulti 为 false 的情况下，是否支持『单击清除所有选框』。
  bool removeOnClick;
  bool allowMove;

  ///默认情况，刷选或者移动选区的时候，会不断得发brushSelected事件，从而告诉外界选中的内容。
  /// 但是频繁的事件可能导致性能问题，或者动画效果很差。所以 brush 组件提供了 brush.throttleType，brush.throttleDelay 来解决这个问题。
  /// true：表示只有停止动作了（即一段时间没有操作了），才会触发事件。时间阈值由 brush.throttleDelay 指定。
  /// false：表示按照一定的频率触发事件，时间间隔由 brush.throttleDelay 指定。
  bool throttleDebounce;
  int throttleDelay;

  LineStyle? borderStyle;
  AreaStyle areaStyle;

  Brush({
    String? id,
    this.enable = false,
    this.mode = BrushType.rect,
    this.supportMulti = true,
    this.selectedMode = SelectedMode.group,
    this.allowMove = true,
    this.borderStyle,
    this.throttleDebounce = false,
    this.throttleDelay = 0,
    this.removeOnClick = true,
    this.areaStyle = const AreaStyle(),
  }) : super(Command.none) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  void clear() {
    value = clearCommand;
  }
}

enum BrushType {
  rect,
  polygon,
  vertical,
  horizontal,
}
