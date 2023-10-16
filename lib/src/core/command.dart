import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/render/chart_render.dart';

///对图表命令的封装
class Command {
  ///[ChartRender]使用
  static const Command none = Command._(0, runAnimation: false);
  static const Command invalidate = Command._(-10000, runAnimation: false);
  static const Command reLayout = Command._(-10001, runAnimation: true);

  ///[LayoutHelper]使用
  static const Command layoutEnd = Command._(-10002, runAnimation: false);
  static const Command layoutUpdate = Command._(-10003, runAnimation: false);

  ///通用
  static const Command configChange = Command._(-10004, runAnimation: true);
  static const Command updateData = Command._(-10005, runAnimation: true);

  ///组件相关
  //Brush
  static const clearBrush = Command._(-10006, runAnimation: false);
  static const hideBrush = Command._(-10007, runAnimation: false);
  static const showBrush = Command._(-10008, runAnimation: false);

  //legend
  static const inverseSelectLegend = Command._(-10009);
  static const selectAllLegend = Command._(-10010);
  static const unselectLegend = Command._(-10011);

  final int code;

  ///是否需要运行动画
  final bool runAnimation;

  Command(
    this.code, {
    this.runAnimation = false,
  }) {
    if (code <= 0) {
      throw ChartError("code must >0");
    }
  }

  const Command._(this.code, {this.runAnimation = true});

  Command copy({bool? runAnimation}) {
    return Command(code, runAnimation: runAnimation ?? this.runAnimation);
  }

  @override
  String toString() {
    return 'Command:$code';
  }

  @override
  int get hashCode {
    return code.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Command && other.code == code;
  }
}
