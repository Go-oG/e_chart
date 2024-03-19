import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///存放布局结果
class LayoutResult {
  double width = 0;
  double height = 0;

  LayoutResult({
    this.width = 0,
    this.height = 0,
  });

  void dispose() {}

  ///子类应该实现该方法
  bool contains(Offset offset) {
    return false;
  }

  void update() {}
}

class MarginResult extends LayoutResult {
  double leftMargin = 0;
  double topMargin = 0;
  double rightMargin = 0;
  double bottomMargin = 0;
  double leftPadding = 0;
  double topPadding = 0;
  double rightPadding = 0;
  double bottomPadding = 0;

  double hPadding() {
    return leftPadding + rightPadding;
  }

  double vPadding() {
    return topPadding + bottomPadding;
  }

  double hMargin() {
    return leftMargin + rightMargin;
  }

  double vMargin() {
    return topMargin + bottomMargin;
  }
}

class RectLayoutResult extends MarginResult {
  double left = 0;
  double top = 0;

  RectLayoutResult();

  Rect toRect() {
    return Rect.fromLTWH(left, top, width, height);
  }

  void fillFromRect(Rect rect) {
    left = rect.left;
    top = rect.top;
    width = rect.width;
    height = rect.height;
  }

  double get right {
    return left + width;
  }

  double get bottom {
    return top + height;
  }

  Offset get center {
    return Offset((left + right) / 2, (top + bottom) / 2);
  }

  Size get size {
    return Size(width, height);
  }
}

class OffsetLayoutResult extends LayoutResult {
  Offset center = Offset.zero;

  OffsetLayoutResult();
}

class CircleLayoutResult extends LayoutResult {
  Offset center = Offset.zero;
  double _radius = 0;

  CircleLayoutResult();

  @override
  set width(double w) {
    super.width = w;
    super.height = w;
    _radius = w / 2;
  }

  @override
  set height(double h) {
    super.height = h;
    super.width = h;
    _radius = h / 2;
  }

  set radius(double r) {
    _radius = r;
    super.width = super.height = r * 2;
  }

  double get radius => _radius;
}

class ArcLayoutResult extends LayoutResult {
  Arc arc = Arc();

  ArcLayoutResult([Arc? arc]) {
    if (arc != null) {
      this.arc = arc;
    }
  }
}

class LineLayoutResult extends LayoutResult {
  Offset start = Offset.zero;

  Offset end = Offset.zero;

  LineLayoutResult();
}

class PathLayoutResult extends LayoutResult {
  Path path = Path();

  PathLayoutResult();
}

class PolygonLayoutResult extends LayoutResult {
  List<Offset> _points = [];

  List<Offset> get points {
    return _points;
  }

  set points(List<Offset> p) {
    this._points = p;
  }

  PolygonLayoutResult();
}
