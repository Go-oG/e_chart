import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class Edge extends DataNode<EdgeAttr, EdgeItemData> {
  final GraphNode source;
  final GraphNode target;

  Edge(EdgeItemData data, int dataIndex, this.source, this.target)
      : super(
          data,
          dataIndex,
          0,
          EdgeAttr(),
          AreaStyle.empty,
          LineStyle.empty,
          LabelStyle.empty,
        );

  @override
  bool contains(Offset offset) {
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {}

  @override
  void updateStyle(Context context, covariant GraphSeries series) {}

  double get x => attr.x;

  double get y => attr.y;

  double get width => attr.width;

  double get height => attr.height;

  String get id => data.id;

  set x(double v) => attr.x = v;

  set y(double v) => attr.y = v;

  set width(double v) => attr.width = v;

  set height(double v) => attr.height = v;

  num get minLen => data.minLen;

  num get weight => data.weight;

  num get labelOffset => data.labelOffset;

  LabelPosition get labelPos => data.labelPos;

  List<Offset> get points => attr.points;

  set points(List<Offset> ol) => attr.points = ol;

  int get index => attr.index;

  set index(int i) => attr.index = i;
}

class EdgeAttr {
  int index = 0;
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
  List<Offset> points = [];
}
