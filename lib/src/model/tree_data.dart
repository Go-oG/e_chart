import 'package:e_chart/e_chart.dart';

class TreeData {
  final String? id;
  List<TreeData> _children = [];
  TreeData? parent;
  num value;

  DynamicText? label;

  TreeData(this.value, {this.label, this.id});

  TreeData.label(this.label, {this.id}) : value = 0;

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
  int get hashCode {
    if (id == null || id!.isEmpty) {
      return super.hashCode;
    }
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! TreeData) {
      return false;
    }
    bool a = other.id == null || other.id!.isEmpty;
    bool b = id == null || id!.isEmpty;
    if (a != b) {
      return false;
    }
    return a ? true : (other.id! == id!);
  }

  @override
  String toString() {
    return (label == null || label!.isEmpty) ? '$value' : '$label';
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
