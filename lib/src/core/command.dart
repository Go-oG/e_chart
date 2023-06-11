///对图表命令的封装
class Command {
  ///[SeriesLayout]使用
  static const Command none = Command(0);
  static const Command invalidate = Command(-1);
  static const Command reLayout = Command(-2);
  static const Command insertData = Command(-3);
  static const Command deleteData = Command(-4);
  static const Command updateData = Command(-5);
  static const Command configChange = Command(-6);
  static const Command layoutEnd = Command(-7);
  static const Command layoutUpdate = Command(-8);

  final int code;

  ///是否需要运行动画
  final bool runAnimation;

  const Command(
    this.code, {
    this.runAnimation = true,
  });

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
