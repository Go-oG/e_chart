import 'package:e_chart/e_chart.dart';

class TreeData extends ItemData {
  static final TreeData empty = TreeData(double.nan, id: "TE0101010101");
  List<TreeData> _children = [];
  TreeData? parent;

  TreeData(super.value, {super.name, super.id});

  TreeData addData(TreeData data) {
    if (data.parent != null && data.parent != this) {
      throw ChartError('Parent 已存在');
    }
    data.parent = this;
    _children.add(data);
    return this;
  }

  TreeData addDataList(Iterable<TreeData> list) {
    for (var data in list) {
      addData(data);
    }
    return this;
  }

  TreeData removeData(TreeData data, [bool clearParent = true]) {
    _children.remove(data);
    if (clearParent) {
      data.parent = null;
    }
    return this;
  }

  TreeData clear([bool clearParent = true]) {
    if (clearParent) {
      for (var c in _children) {
        c.parent = null;
      }
    }
    _children = [];
    return this;
  }

  int get childCount => _children.length;

  bool get hasChild => childCount > 0;

  bool get notChild => !hasChild;

  List<TreeData> get children => _children;

  @override
  String toString() {
    return "$runtimeType label:$name value:${value.toStringAsFixed(2)}";
  }

  static int computeDeep(TreeData data) {
    List<TreeData> dl = [data];
    int deep = 0;
    List<TreeData> next = [];
    while (dl.isNotEmpty) {
      for (var element in dl) {
        next.addAll(element.children);
      }
      if (next.isEmpty) {
        break;
      }
      deep += 1;
      dl = next;
      next = [];
    }
    return deep;
  }
}
