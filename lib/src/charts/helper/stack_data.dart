import '../../model/index.dart';
import '../../utils/uuid_util.dart';

class StackGroupData<T> {
  late final String id;
  List<T?> data;
  int xAxisIndex;
  int yAxisIndex;

  String? stackId;
  StackStrategy strategy;

  StackGroupData(
    this.data, {
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
    String? id,
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
    return other is StackGroupData && other.id == id;
  }

  bool get isStack {
    return stackId != null && stackId!.isNotEmpty;
  }

  bool get isNotStack {
    return !isStack;
  }
}

class StackItemData extends ItemData {
  DynamicData x;

  num stackUp = 0;
  num stackDown = 0;

  StackItemData(this.x, num value, {super.id, super.label}) : super(value: value) {
    stackUp = value;
    stackDown = 0;
  }

  @override
  bool operator ==(Object other) {
    return other is StackItemData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
