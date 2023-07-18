import '../../model/index.dart';
import '../../utils/uuid_util.dart';

class BaseGroupData<T> {
  late final String id;
  List<T?> data;
  int? xAxisIndex;
  int? yAxisIndex;
  int? polarAxisIndex;
  String? stackId;
  StackStrategy strategy;

  BaseGroupData(
    this.data, {
    this.xAxisIndex,
    this.yAxisIndex,
        this.polarAxisIndex,
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
    return other is BaseGroupData && other.id == id;
  }

  bool get isStack {
    return stackId != null && stackId!.isNotEmpty;
  }

  bool get isNotStack {
    return !isStack;
  }
}

class BaseItemData {
  late final String id;
  num up;
  num down = 0;
  DynamicData x;

  BaseItemData(this.x, this.up, this.down, {String? id}) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
    if (up < down) {
      num d = up;
      up = down;
      down = d;
    }
  }

  BaseItemData.number(this.x, this.up, {String? id}) {
    down = 0;
    if (up < down) {
      num d = up;
      up = down;
      down = d;
    }
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
  }

  @override
  bool operator ==(Object other) {
    return other is BaseItemData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
