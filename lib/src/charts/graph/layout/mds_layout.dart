import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:ml_linalg/axis.dart' as ml;
import 'package:ml_linalg/matrix.dart';
import 'package:scidart/numdart.dart' as sv;


///高维数据降维算法布局
///Ref:https://github.com/antvis/layout/blob/master/src/layout/mds.ts
class MDSLayout extends GraphLayout {
  List<SNumber> center;
  Fun3<GraphNode, GraphNode, num>? distanceFun;
  num linkDistance;

  ///存储距离矩阵
  List<List<double>> scaledDistances = [];
  List<ChartOffset> positions = [];

  MDSLayout({
    this.distanceFun,
    this.linkDistance = 40,
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.nodeSize,
    super.sizeFun,
    super.nodeSpaceFun,
    super.sort,
    super.workerThread,
  });

  @override
  void onLayout( LayoutType type){
    stopLayout();
    clearInterrupt();
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
    clear();
    List<GraphNode> nodes = graph.nodes;
    if (nodes.isEmpty) {
      notifyLayoutEnd();
      return;
    }
    Offset centerOffset = Offset(center[0].convert(width), center[1].convert(height));
    if (nodes.length == 1) {
      nodes[0].x = centerOffset.dx;
      nodes[0].y = centerOffset.dy;
      notifyLayoutEnd();
      return;
    }

    /// 图论距离（最短路径距离）矩阵
    List<List<double>> distances;
    if (distanceFun != null) {
      distances = [];
      for (var c in graph.nodes) {
        checkInterrupt();
        List<double> dl = [];
        for (var n in graph.nodes) {
          dl.add(distanceFun!.call(c, n).toDouble());
        }
        distances.add(dl);
      }
    } else {
      List<List<double>> adjMatrix = getAdjMatrix(graph, false);
      distances = floydWarshall(adjMatrix);
    }
    _handleInfinity(distances);

    ///根据链接缩放理想的边长距离
    List<List<double>> scaledD = scaleMatrix(distances, linkDistance);
    scaledDistances = scaledD;

    ///MDS
    List<ChartOffset> positions = runMDS(scaledDistances);
    this.positions = positions;
    for (int i = 0; i < positions.length; i++) {
      checkInterrupt();
      var node = nodes[i];
      var p = positions[i];
      node.x = p.x + centerOffset.dx;
      node.y = p.y + centerOffset.dy;
    }
    notifyLayoutEnd();
  }

  @override
  void stopLayout() {
    super.stopLayout();
    interrupt();
  }

  void clear() {
    scaledDistances = [];
    positions = [];
  }

  ///输出值代表样本的低位坐标
  List<ChartOffset> runMDS(List<List<double>> distanceList, [int dimension = 2]) {
    try {
      ///构建多维空间距离矩阵
      Matrix matrix = Matrix.fromList(distanceList).pow(2);
      matrix = matrix * -0.5;
      var rowMeans = matrix.mean(ml.Axis.rows);
      var colMeans = matrix.mean(ml.Axis.columns);
      var totalMean = matrix.sum() / (matrix.columnCount * matrix.rowCount);
      matrix = matrix + totalMean;
      matrix = matrix.mapRows((row) => row - rowMeans);
      matrix = matrix.mapColumns((column) => column - colMeans);

      ///提取SVD
      List<sv.Array> arrayList = [];
      for (var element in matrix.rows) {
        checkInterrupt();
        arrayList.add(sv.Array(element.toList()));
      }
      var ret = sv.SVD(sv.Array2d(arrayList));
      var eigenMatrix = Matrix.diagonal(ret.singularValues().toList());
      eigenMatrix = eigenMatrix.pow(0.5);
      List<double> eigenValues = [];
      for (int i = 0; i < eigenMatrix.rowCount; i++) {
        checkInterrupt();
        eigenValues.add(eigenMatrix[i][i]);
      }
      sv.Array2d u = ret.U();
      List<List<double>> leftSingularVectors = [];
      for (var uc in u) {
        checkInterrupt();
        leftSingularVectors.add(uc.toList());
      }
      var mulM = Matrix.fromList([eigenValues]);
      List<List<double>> resultList = List.from(leftSingularVectors.map<List<double>>((row) {
        checkInterrupt();
        Matrix tm = Matrix.fromList([row]).multiply(mulM);
        return tm.getRow(0).toList().sublist(0, dimension);
      }));
      List<ChartOffset> rl = [];
      for (var t in resultList) {
        checkInterrupt();
        rl.add(ChartOffset(t[0], t[1]));
      }
      return rl;
    } catch (e) {
      List<ChartOffset> res = [];
      Random random = Random();
      for (int i = 0; i < distanceList.length; i++) {
        checkInterrupt();
        var x = random.nextDouble() * linkDistance;
        var y = random.nextDouble() * linkDistance;
        res.add(ChartOffset(x, y));
      }
      return res;
    }
  }

  void _handleInfinity(List<List<double>> distances) {
    double maxDistance = -99999999;
    for (var row in distances) {
      checkInterrupt();
      for (var value in row) {
        checkInterrupt();
        if (value.isInfinite) {
          continue;
        }
        if (value > maxDistance) {
          maxDistance = value;
        }
      }
    }

    for (int i = 0; i < distances.length; i++) {
      var row = distances[i];
      for (int j = 0; j < row.length; j++) {
        var value = row[j];
        if (value.isInfinite) {
          distances[i][j] = maxDistance;
        }
      }
    }
  }
}

List<List<double>> getAdjMatrix(Graph graph, bool directed) {
  List<GraphNode> nodes = graph.nodes;
  List<Edge<GraphNode>> edges = graph.edges;
  List<List<double>> matrix = [];
  Map<String, int> nodeMap = {};

  if (nodes.isEmpty) {
    throw FlutterError('invalid nodes data!');
  }
  if (nodes.isNotEmpty) {
    for (int i = 0; i < nodes.length; i++) {
      nodeMap[nodes[i].id] = i;
      matrix.add(List.filled(nodes.length, 0, growable: true));
    }
  }
  for (var e in edges) {
    var source = e.source;
    var target = e.target;
    int? sIndex = nodeMap[source.id];
    int? tIndex = nodeMap[target.id];
    if (sIndex == null || tIndex == null) {
      continue;
    }
    matrix[sIndex][tIndex] = 1;
    if (!directed) {
      matrix[tIndex][sIndex] = 1;
    }
  }
  return matrix;
}

List<List<double>> floydWarshall(List<List<double>> adjMatrix) {
  int size = adjMatrix.length;
  List<List<double>> dist = List.generate(size, (index) => List.generate(size, (index) => 0));
  for (int i = 0; i < size; i += 1) {
    for (int j = 0; j < size; j += 1) {
      if (i == j) {
        dist[i][j] = 0;
      } else if (adjMatrix[i][j] == 0 || adjMatrix[i][j] == 0) {
        dist[i][j] = double.infinity;
      } else {
        dist[i][j] = adjMatrix[i][j];
      }
    }
  }
// floyd
  for (int k = 0; k < size; k += 1) {
    for (int i = 0; i < size; i += 1) {
      for (int j = 0; j < size; j += 1) {
        if (dist[i][j] > dist[i][k] + dist[k][j]) {
          dist[i][j] = dist[i][k] + dist[k][j];
        }
      }
    }
  }
  return dist;
}

List<List<double>> scaleMatrix(List<List<double>> matrix, num ratio) {
  List<List<double>> result = [];
  for (var row in matrix) {
    result.add(List.from(row.map((e) => e * ratio)));
  }
  return result;
}
