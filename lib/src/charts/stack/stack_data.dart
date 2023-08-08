import '../../model/index.dart';
import '../../utils/uuid_util.dart';

class StackGroupData<T> {
  late final String id;
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
    String? stackId,
    this.strategy = StackStrategy.all,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    this._stackId = stackId;
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
  DynamicData x;
  DynamicData y;
  DynamicText? label;
  num stackUp = 0;
  num stackDown = 0;

  StackItemData(this.x, this.y, {String? id, this.label}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    if (!x.isNum && !y.isNum) {
      throw ChartError('x 和 y 必须有一个是num类型的数据');
    }
    if (y.isNum) {
      stackUp = y.data;
    } else {
      stackUp = x.data;
    }
    stackDown = 0;
  }

  num get value {
    if (y.isNum) {
      return y.data;
    }
    return x.data;
  }

  @override
  bool operator ==(Object other) {
    return other is StackItemData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
