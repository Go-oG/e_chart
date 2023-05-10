import 'package:chart_xutil/chart_xutil.dart';

import '../model/enums/select_mode.dart';

extension TreeNodeExt<T extends TreeNode<T>> on TreeNode<T> {
  void updateSelectStatus(bool status, {SelectedMode mode = SelectedMode.single}) {
    select = status;
    if (mode == SelectedMode.single) {
      return;
    }
    if (mode == SelectedMode.child) {
      List<T> cl = List.from(children);
      while (cl.isNotEmpty) {
        T node = cl.removeAt(0);
        node.select = status;
        cl.addAll(node.children);
      }
      return;
    }
    if (mode == SelectedMode.parent) {
      T? node = parent;
      while (node != null) {
        node.select = status;
        node = node.parent;
      }
      return;
    }
    T? node = parent;
    while (node != null) {
      node.select = status;
      node = node.parent;
    }
    List<T> cl = List.from(children);
    while (cl.isNotEmpty) {
      T node = cl.removeAt(0);
      node.select = status;
      cl.addAll(node.children);
    }
  }
}
