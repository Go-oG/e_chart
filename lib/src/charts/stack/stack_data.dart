import 'package:e_chart/e_chart.dart';

class StackGroupData<T> {
  late final String id;
  late final String name;
  int styleIndex = 0;
  List<T?> data;
  int xAxisIndex;
  int yAxisIndex;

  String? _stackId;

  String? get stackId => _stackId;
  StackStrategy strategy;

  SNumber? barSize;
  SNumber? barMaxSize;
  SNumber? barMinSize;

  StackGroupData(
    this.data, {
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
    this.barSize,
    this.barMaxSize,
    this.barMinSize = const SNumber(1, false),
    String? id,
    String? name,
    String? stackId,
    this.strategy = StackStrategy.all,
    this.styleIndex = 0,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    this._stackId = stackId;
    this.name = name ?? '';
  }

  set stackId(String? id) {
    _stackId = id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is StackGroupData && other.id == id;
  }

  bool get isStack {
    return stackId != null && stackId!.isNotEmpty;
  }

  bool get isNotStack {
    return !isStack;
  }
}

class StackItemData {
  late final String id;
  dynamic x;
  dynamic y;
  DynamicText? label;

  num stackUp = 0;

  num stackDown = 0;

  StackItemData(this.x, this.y, {String? id, this.label}) {
    checkDataType(x);
    checkDataType(y);
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    if (x is! num && y is! num) {
      throw ChartError('x 和 y 必须有一个是num类型的数据');
    }
    if (y is num) {
      stackUp = y;
    } else {
      stackUp = x;
    }
    stackDown = 0;
  }

  num get value {
    if (y is num) {
      return y;
    }
    return x;
  }

  num get minValue {
    return 0;
  }

  num get maxValue {
    return value;
  }

  num get aveValue {
    return value / 2;
  }

  @override
  bool operator ==(Object other) {
    return other is StackItemData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
