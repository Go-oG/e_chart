import '../../component/index.dart';
import '../../core/view_state.dart';
import '../../utils/diff.dart';

class DataNode<P, D> with ViewStateProvider implements NodeAccessor<P, D> {
  final int dataIndex;
  final int? groupIndex;
  final D data;
  P attr;

  AreaStyle? areaStyle;
  LineStyle? lineStyle;
  LabelStyle? labelStyle;

  DataNode(this.data, this.dataIndex, this.groupIndex, this.attr);

  @override
  bool operator ==(Object other) {
    return other is DataNode && other.data == data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  D getData() => data;

  @override
  P getAttr() {
    return attr;
  }

  @override
  void setAttr(P po) {
    attr = po;
  }
}
