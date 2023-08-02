import 'package:e_chart/e_chart.dart';

class DataNode<P, D> with ViewStateProvider implements NodeAccessor<P, D> {
  final D data;

  P attr;

  DataNode(this.data, this.attr);

  @override
  bool operator ==(Object other) {
    return other is DataNode && other.data == data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  D get d => data;

  @override
  P getP() {
    return attr;
  }

  @override
  void setP(P po) {
    attr = po;
  }
}
