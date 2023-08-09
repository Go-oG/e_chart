import '../stack_data.dart';

class WrapData<T extends StackItemData, P extends StackGroupData<T>> {
  final T? data;
  final P parent;

  ///标识该数据应该使用的样式索引
  final int styleIndex;

  ///标识该数据所属的Group组的序号
  final int groupIndex;

  ///标识该数据在其Group中的位置
  final int dataIndex;

  const WrapData(this.data, this.parent, this.groupIndex, this.dataIndex,this.styleIndex);

  @override
  int get hashCode {
    return Object.hash(parent, data);
  }

  @override
  bool operator ==(Object other) {
    if (other is! WrapData) {
      return false;
    }
    return other.parent == parent && other.data == data;
  }
}
