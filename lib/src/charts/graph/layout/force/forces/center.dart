import 'package:e_chart/e_chart.dart';


///中心力均匀地平移节点到给定位置 ⟨x,y⟩。
///该Force改变了节点的位置,但没有改变速度(因为这样做通常会导致节点超调并围绕所需中心振荡)
///此力有助于将节点保持在视图的中心，
///并且与[XForce]、[YForce]不同，它不会改变节点的相对位置。
class CenterForce extends Force {
  ///中心点坐标，默认为<0，0>
  List<SNumber> center;

  ///居中力的强度。例如强度为0.05时会软化节点移动(当新节点进入或者退出时)
  ///默认为 1
  double _strength = 1;

  CenterForce([this.center=const [SNumber.zero, SNumber.zero]]);

  //==========布局相关参数=============
  late double _x, _y;
  List<GraphNode> _nodes = [];

  @override
  void initialize(Context context, Graph graph, LCG lcg, num width, num height) {
    super.initialize(context, graph, lcg, width, height);
    _x = center[0].convert(width);
    _y = center[1].convert(height);
    _nodes = graph.nodes;
  }

  @override
  void force([double alpha = 1]) {
    if(_nodes.isEmpty){return;}
    double sx = 0;
    double sy = 0;
    for (var node in _nodes) {
      sx += node.x;
      sy += node.y;
    }
    int nodeCount = _nodes.length;
    for (var node in _nodes) {
      sx = (sx / nodeCount - _x) * _strength;
      sy = (sy / nodeCount - _y) * _strength;
      node.x -= sx.floor();
      node.y -= sy.floor();
    }
  }

  CenterForce setX(SNumber x) {
    center[0] = x;
    _x = x.convert(width);
    return this;
  }

  CenterForce setY(SNumber y) {
    center[1] = y;
    _y = y.convert(height);
    return this;
  }

  CenterForce setStrength(double v) {
    _strength = v;
    return this;
  }
}
