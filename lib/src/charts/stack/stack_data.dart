import 'package:e_chart/e_chart.dart';

class StackGroupData<T> {
  late final String id;
  late final String name;
  int styleIndex = 0;
  List<T?> data;
  int xAxisIndex;
  int yAxisIndex;

  String? stackId;
  bool stackUsePercent;

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
    this.stackId,
    this.stackUsePercent = false,
    this.styleIndex = 0,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    this.name = name ?? '';
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

class StackItemData extends BaseItemData {
  dynamic x;
  dynamic y;

  StackItemData(this.x, this.y, {super.id, super.name}) {
    checkDataType(x);
    checkDataType(y);
    if (x is! num && y is! num) {
      throw ChartError('x 和 y 必须有一个是num类型的数据');
    }
    if (x == null || y == null) {
      throw ChartError("NullPointException");
    }
  }

  num get value {
    if (y is num && x is num) {
      throw ChartError(" x 和 y都是num 请重写该方法并返回正确的值");
    }
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
  String toString() {
    return '$runtimeType x:${x} y:$y';
  }
}
