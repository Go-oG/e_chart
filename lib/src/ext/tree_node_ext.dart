import 'package:e_chart/e_chart.dart';

extension TreeNodeExt<T, N extends ChartTree<T, N>> on N {
  void updateSelectStatus(bool status, {SelectedMode mode = SelectedMode.single}) {
    if (status) {
      addState(ViewState.selected);
    } else {
      removeState(ViewState.selected);
    }
    if (mode == SelectedMode.single) {
      return;
    }
    N? node = parent;
    while (node != null) {
      if (status) {
        node.addState(ViewState.selected);
      } else {
        node.removeState(ViewState.selected);
      }
      node = node.parent;
    }
    List<N> cl = List.from(children);
    while (cl.isNotEmpty) {
      N node = cl.removeAt(0);
      if (status) {
        node.addState(ViewState.selected);
      } else {
        node.removeState(ViewState.selected);
      }
      cl.addAll(node.children);
    }
  }
}
