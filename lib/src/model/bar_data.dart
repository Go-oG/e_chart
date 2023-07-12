import 'package:e_chart/e_chart.dart';

class GridGroupData {
  late final String id;
  List<GridItemData> data;

  ///控制柱状图的大小（具体的含义取决于布局的方向）
  SNumber? barSize;
  SNumber? barMaxSize;
  SNumber? barMinSize;

  int? xAxisIndex;
  int? yAxisIndex;

  String? stackId;
  StackStrategy strategy;

  GridGroupData(this.data, {
    this.xAxisIndex,
    this.yAxisIndex,
    String? id,
    this.barSize,
    this.barMaxSize,
    this.barMinSize = const SNumber(1, false),
    this.stackId,
    this.strategy = StackStrategy.all,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is GridGroupData && other.id == id;
  }

  bool get isStack {
    return stackId != null && stackId!.isNotEmpty;
  }

  bool get isNotStack {
    return !isStack;
  }
}

class GridItemData {
  late final String id;
  late num up;
  late num down;
  DynamicData x;

  GridItemData(this.x, this.up, {String? id}) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
    down = up;
  }

  GridItemData.waterfall(this.x, this.down, this.up, {String? id}) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
  }

  GridItemData.number(this.x, num data, {String? id}) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
    up = data;
    down = 0;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is GridItemData && other.id == id;
  }
}
