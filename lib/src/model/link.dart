import 'dart:ui';

class Link<T> {
  final T source;
  final T target;
  int index = 0;
  num weight = 0;

  ///存储位置
  final List<Offset> points = [];

  Link(this.source, this.target);
}
