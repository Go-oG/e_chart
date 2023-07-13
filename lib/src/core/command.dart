import 'package:e_chart/e_chart.dart';

///对图表命令的封装
class Command {
  ///[SeriesLayout]使用
  static const Command none = Command._(0, runAnimation: false);
  static const Command invalidate = Command._(-1, runAnimation: false);
  static const Command reLayout = Command._(-2, runAnimation: true);
  static const Command updateData = Command._(-3, runAnimation: true);
  static const Command configChange = Command._(-4, runAnimation: true);

  ///[ChartLayout]使用
  static const Command layoutEnd = Command._(-5, runAnimation: false);
  static const Command layoutUpdate = Command._(-6, runAnimation: false);

  final int code;

  ///是否需要运行动画
  final bool runAnimation;

  Command(
    this.code, {
    this.runAnimation = true,
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
