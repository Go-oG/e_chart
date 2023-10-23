import 'package:e_chart/e_chart.dart';

extension TreeNodeExt<D,  A, T extends BaseTreeData<A, T>> on BaseTreeData<A, T> {
  void updateSelectStatus(bool status, {SelectedMode mode = SelectedMode.single}) {
    if (status) {
      addState(ViewState.selected);
    } else {
      removeState(ViewState.selected);
    }
    if (mode == SelectedMode.single) {
      return;
    }
    T? node = parent;
    while (node != null) {
      if (status) {
        node.addState(ViewState.selected);
      } else {
        node.removeState(ViewState.selected);
      }
      node = node.parent;
    }
    List<T> cl = List.from(children);
    while (cl.isNotEmpty) {
      T node = cl.removeAt(0);
      if (status) {
        node.addState(ViewState.selected);
      } else {
        node.removeState(ViewState.selected);
      }
      cl.addAll(node.children);
    }
  }
}
