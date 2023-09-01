import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'radia_param.dart';
import 'radia_param.dart' as rp;

///辐射状布局
///Ref:https://github.com/antvis/layout/blob/master/src/layout/radial/radial.ts
class RadialLayout extends GraphLayout {
  ///图的中心
  List<SNumber> center;

  //焦点节点
  GraphNode? focusNode;

  //边长度
  num linkDistance;

  //最大迭代次数
  int maxIteration;

  //每圈距离上一圈的距离
  num? radiusGap;

  //是否防重叠
  bool preventOverlap;

  /// 防止重叠步骤的最大迭代数
  int maxPreventOverlapIteration;

  ///是否为严格的Radial布局
  bool strictRadial;

  /// 同层节点根据sort函数排列的强度，值越大，sortBy计算出的距离越靠近
  num sortStrength;

  Fun3<GraphNode, num, num>? sortBy = (node, v) {
    return v;
  };

  bool sortByData = true;

  RadialLayout({
    this.center = const [SNumber.percent(50), SNumber(50, true)],
    this.linkDistance = 30,
    this.maxIteration = 500,
    this.focusNode,
    this.radiusGap = 30,
    this.preventOverlap = false,
    this.maxPreventOverlapIteration = 500,
    this.strictRadial = true,
    this.sortStrength = 10,
    this.sortByData = true,
    this.sortBy,
    super.nodeSpaceFun,
    super.workerThread = true,
  });

  @override
  void onLayout(LayoutType type) {
    if (workerThread) {
      Future.doWhile(() {
        runLayout(context, series.graph, width, height);
        return false;
      });
    } else {
      runLayout(context, series.graph, width, height);
    }
  }

  void runLayout(Context context, Graph graph, num width, num height) {
    var nodes = graph.nodes;
    if (nodes.isEmpty) {
      notifyLayoutEnd();
      return;
    }
    LayoutProps props = LayoutProps();
    props.width = width;
    props.height = height;
    props.center = Offset(center[0].convert(width), center[1].convert(height));
    if (nodes.length == 1) {
      nodes[0].x = props.center.dx;
      nodes[0].y = props.center.dy;
      notifyLayoutEnd();
      return;
    }

    ///使用GridLayout预先布局一次
    GraphLayout gridLayout = GraphGridLayout(
      preventOverlap: true,
      workerThread: false,
      nodeSpaceFun: nodeSpaceFun,
    );
    gridLayout.doLayout(boxBound, globalBoxBound, LayoutType.none);

    // 计算focusNode和其索引
    GraphNode focusNode = this.focusNode ?? nodes.first;
    int focusIndex = nodes.indexOf(focusNode);
    if (focusIndex < 0) {
      focusIndex = 0;
    }
    props.focusIndex = focusIndex;
    props.focusNode = nodes[focusIndex];

    // 计算节点之间的间距
    List<List<double>> adjMatrix = getAdjMatrix(graph, false);
    props.distances = floydWarshall(adjMatrix);
    num maxDistance = _maxToFocus(props.distances, focusIndex);

    //将未连接节点中的第一个节点替换为圆（maxDistance+1）
    _handleInfinity(props.distances, focusIndex, maxDistance + 1);

    //从每个节点到focusNode的最短路径距离
    List<double> focusNodeD = props.distances[focusIndex];
    num semiWidth = width - props.center.dx > props.center.dx ? props.center.dx : width - props.center.dx;
    num semiHeight = height - props.center.dy > props.center.dy ? props.center.dy : height - props.center.dy;
    if (semiWidth == 0) {
      semiWidth = width / 2;
    }
    if (semiHeight == 0) {
      semiHeight = height / 2;
    }
    num maxRadius = min([semiWidth, semiHeight]);
    num maxD = max(focusNodeD);
    if (radiusGap == null || radiusGap! < 0) {
      props.radiusGap = maxRadius / maxD;
    } else {
      props.radiusGap = radiusGap!;
    }
    // 存储每层半径
    List<num> radii = List.generate(focusNodeD.length, (i) => focusNodeD[i] * props.radiusGap, growable: true);
    props.radii = radii;
    List<List<double>> eIdealD = _eIdealDisMatrix(props, nodes);
    props.eIdealDistances = eIdealD;
    props.weights = _getWeightMatrix(eIdealD);
    MDSLayout mds = MDSLayout(linkDistance: linkDistance);
    props.positions = mds.runMDS(eIdealD);
    Random random = Random();
    for (var p in props.positions) {
      if (p.x.isNaN) {
        p.x = random.nextDouble() * linkDistance;
      }
      if (p.y.isNaN) {
        p.y = random.nextDouble() * linkDistance;
      }
    }
    each(props.positions, (p, i) {
      var node = nodes[i];
      node.x = p.x + props.center.dx;
      node.y = p.y + props.center.dy;
    });
    for (var p in props.positions) {
      p.x -= props.positions[focusIndex].x;
      p.y -= props.positions[focusIndex].y;
    }
    for (int i = 0; i <= maxIteration; i++) {
      num param = i / maxIteration;
      runStep(props, param);
    }
    //处理节点重叠
    if (preventOverlap) {
      ///使用的是径向力
      num nodeSizeFunc(GraphNode a) {
        num space = getNodeSpace(a);
        return a.size.longestSide+space;
      }

      var params = RadialParam(
        nodes,
        nodeSizeFunc,
        adjMatrix,
        props.positions,
        radii,
        height,
        width,
        strictRadial,
        focusIndex,
        maxPreventOverlapIteration,
        props.positions.length / 4.5,
      );
      var force = rp.RadialForce(params);
      props.positions = force.layout();
    }
    // 移动节点到中心
    each(props.positions, (p, i) {
      nodes[i].x = p.x + props.center.dx;
      nodes[i].y = p.y + props.center.dy;
    });
    notifyLayoutEnd();
  }

  void runStep(LayoutProps props, num param) {
    var positions = props.positions;
    var radii = props.radii;
    var D = props.eIdealDistances;
    var W = props.weights;

    num vparam = 1 - param;
    int focusIndex = props.focusIndex;
    each(positions, (v, i) {
      var v = positions[i];
      double originDis = v.distance2(Offset.zero);
      num reciODis = originDis == 0 ? 0 : 1 / originDis;
      if (i == focusIndex) {
        return;
      }
      num xMolecule = 0;
      num yMolecule = 0;
      num denominator = 0;
      each(positions, (u, j) {
        if (i == j) {
          return;
        }
        num edis = v.distance(u);
        num reciEdis = edis == 0 ? 0 : 1 / edis;
        var idealDis = D[j][i];
        denominator += W[i][j];
        xMolecule += W[i][j] * (u.x + idealDis * (v.x - u.x) * reciEdis);
        yMolecule += W[i][j] * (u.y + idealDis * (v.y - u.y) * reciEdis);
      });

      num reciR = radii[i] == 0 ? 0 : 1 / radii[i];
      denominator *= vparam;
      denominator += param * reciR * reciR;
      // x
      xMolecule *= vparam;
      xMolecule += param * reciR * v.x * reciODis;
      v.x = xMolecule / denominator;
      // y
      yMolecule *= vparam;
      yMolecule += param * reciR * v.y * reciODis;
      v.y = yMolecule / denominator;
    });
  }

  num _maxToFocus(List<List<double>> matrix, int focusIndex) {
    num max = 0;
    for (int i = 0; i < matrix[focusIndex].length; i++) {
      if (matrix[focusIndex][i].isInfinite) {
        continue;
      }
      max = matrix[focusIndex][i] > max ? matrix[focusIndex][i] : max;
    }
    return max;
  }

  void _handleInfinity(List<List<double>> matrix, int focusIndex, double step) {
    int length = matrix.length;
    for (int i = 0; i < length; i++) {
      // matrix 关注点对应行的 Inf 项
      if (matrix[focusIndex][i].isInfinite) {
        matrix[focusIndex][i] = step;
        matrix[i][focusIndex] = step;
        // 遍历 matrix 中的 i 行，i 行中非 Inf 项若在 focus 行为 Inf，则替换 focus 行的那个 Inf
        for (int j = 0; j < length; j++) {
          if ((!matrix[i][j].isInfinite) && matrix[focusIndex][j].isInfinite) {
            matrix[focusIndex][j] = step + matrix[i][j];
            matrix[j][focusIndex] = step + matrix[i][j];
          }
        }
      }
    }
    // 处理其他行的 Inf。根据该行对应点与 focus 距离以及 Inf 项点 与 focus 距离，决定替换值
    for (int i = 0; i < length; i++) {
      if (i == focusIndex) {
        continue;
      }
      for (int j = 0; j < length; j++) {
        if (matrix[i][j].isInfinite) {
          double minus = (matrix[focusIndex][i] - matrix[focusIndex][j]).abs();
          minus = minus == 0 ? 1 : minus;
          matrix[i][j] = minus;
        }
      }
    }
  }

  List<List<double>> _eIdealDisMatrix(LayoutProps props, List<GraphNode> nodes) {
    if (nodes.isEmpty) return [];
    var D = props.distances;
    var linkDis = linkDistance;
    var radii = props.radii;
    var unitRadius = props.radiusGap;
    List<List<double>> result = [];
    if (D.isNotEmpty) {
      for (int i = 0; i < D.length; i++) {
        var row = D[i];
        List<double> newRow = [];
        for (int j = 0; j < row.length; j++) {
          var v = row[j];
          if (i == j) {
            newRow.add(0);
          } else if (radii[i] == radii[j]) {
            if (sortByData) {
              newRow.add((v * ((i - j).abs() * sortStrength)) / (radii[i] / unitRadius));
            } else if (sortBy != null) {
              var iValue = sortBy!.call(nodes[i], radii[i]);
              var jValue = sortBy!.call(nodes[j], radii[j]);
              newRow.add((v * (iValue - jValue).abs() * sortStrength) / (radii[i] / unitRadius));
            } else {
              newRow.add((v * linkDis) / (radii[i] / unitRadius));
            }
          } else {
            newRow.add(v * (linkDis + unitRadius) / 2);
          }
        }
        result.add(newRow);
      }
    }
    return result;
  }

  List<List<double>> _getWeightMatrix(List<List<double>> M) {
    int rows = M.length;
    int cols = M[0].length;
    List<List<double>> result = [];
    for (int i = 0; i < rows; i++) {
      List<double> row = [];
      for (int j = 0; j < cols; j++) {
        if (M[i][j] != 0) {
          row.add(1 / (M[i][j] * M[i][j]));
        } else {
          row.add(0);
        }
      }
      result.add(row);
    }
    return result;
  }
}

class LayoutProps {
  late GraphNode focusNode;
  num radiusGap = 0;
  int focusIndex = 0;
  List<List<double>> distances = [];
  List<List<double>> eIdealDistances = [];
  List<List<double>> weights = [];
  List<num> radii = [];
  List<ChartOffset> positions = [];
  num width = 0;
  num height = 0;
  Offset center = Offset.zero;
}
