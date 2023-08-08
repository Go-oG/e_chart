
import '../model/enums/select_mode.dart';
import '../model/tree_node.dart';

extension TreeNodeExt<T extends TreeNode<T>> on TreeNode<T> {
  void updateSelectStatus(bool status, {SelectedMode mode = SelectedMode.single}) {
    select = status;
    if (mode == SelectedMode.single) {
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
