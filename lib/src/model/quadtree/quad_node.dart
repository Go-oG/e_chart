import 'package:flutter/widgets.dart';

import '../mixin_props.dart';


/// 叶子节点和 父节点 的统一封装
///节点的属性在创建时就已经被确定了
class QuadNode<T> with ExtProps {
  ///作为left节点时使用的属性
  final T? data;
  // 下一个节点(存在相同的点)
  QuadNode<T>? next;

  ///当该对象类型为父节点时 则存在下列属性
  final Map<int, QuadNode<T>> _childMap = {};

  QuadNode({int length = -1, this.data}) {
    if (length != 4 && data == null) {
      throw FlutterError('创建时必须选一个');
    }
    if (length == 4 && data != null) {
      throw FlutterError('只能选一个');
    }
    if (length != 4) {
      _childMap.clear();
    }
  }

  void operator []=(int index, QuadNode<T>? node) {
    if (index < 0 || index >= 4) {
      throw FlutterError('违法参数：只能传入0-3');
    }
    if (node != null) {
      _childMap[index] = node;
    }
  }

  void delete(int index) {
    _childMap.remove(index);
  }

  QuadNode<T>? operator [](int index) {
    if (index < 0 || index >= 4) {
      throw FlutterError('违法参数：只能传入0-3');
    }
    return _childMap[index];
  }

  int get childCount => data == null ? _childMap.length : 0;

  bool get hasChild => data == null ? _childMap.isNotEmpty : false;
}
