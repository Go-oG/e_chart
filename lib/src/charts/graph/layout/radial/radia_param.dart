import 'dart:math';
import 'package:e_chart/e_chart.dart';

class RadialParam {
  List<GraphData> nodes = [];
  List<ChartOffset> positions = [];
  List<List<double>> adjMatrix = [];
  int focusID;
  List<num> radii = [];
  int? iterations;
  num? height;
  num? width;
  num? speed;
  num? gravity;
  Fun2<GraphData, num> nodeSizeFunc;
  num k;
  bool strictRadial;

  RadialParam(
    this.nodes,
    this.nodeSizeFunc,
    this.adjMatrix,
    this.positions,
    this.radii,
    this.height,
    this.width,
    this.strictRadial,
    this.focusID,
    this.iterations,
    this.k,
  );
}

class RadialForce {
  late List<ChartOffset> positions;
  late List<List<double>> adjMatrix;
  late int focusID;
  late List<num> radii;
  late int iterations;
  late num height;
  late num width;
  late num speed;
  late num gravity;
  late Fun2<GraphData, num> nodeSizeFunc;
  late num k;
  late bool strictRadial;
  late List<GraphData> nodes;
  num? maxDisplace;
  List<ChartOffset> disp = [];

  RadialForce(RadialParam params) {
    positions = params.positions;
    adjMatrix = params.adjMatrix;
    focusID = params.focusID;
    radii = params.radii;
    iterations = params.iterations ?? 10;
    height = params.height ?? 10;
    width = params.width ?? 10;
    speed = params.speed ?? 100;
    gravity = params.gravity ?? 10;
    nodeSizeFunc = params.nodeSizeFunc;
    k = params.k == 0 ? 5 : params.k;
    strictRadial = params.strictRadial;
    nodes = params.nodes;
  }

  List<ChartOffset> layout() {
    var positions = this.positions;
    List<ChartOffset> disp = [];
    int iterations = this.iterations;
    num maxDisplace = width / 10;
    this.maxDisplace = maxDisplace;
    this.disp = disp;
    for (int i = 0; i < iterations; i++) {
      disp = List.generate(positions.length, (index) => ChartOffset(0, 0));
      getRepulsion();
      updatePositions();
    }
    return positions;
  }

  void getRepulsion() {
    var positions = this.positions;
    var nodes = this.nodes;
    this.disp = List.generate(positions.length, (index) => ChartOffset(0, 0));
    var disp = this.disp;
    var k = this.k;
    var radii = this.radii;
    for (int i = 0; i < positions.length; i++) {
      var v = positions[i];
      disp[i] = ChartOffset(0, 0);
      for (int j = 0; j < positions.length; j++) {
        var u = positions[j];
        if (i == j) {
          continue;
        }
        if (radii[i] != radii[j]) {
          continue;
        }
        var vecx = v.x - u.x;
        var vecy = v.x - u.y;
        var vecLength = sqrt(vecx * vecx + vecy * vecy);
        if (vecLength == 0) {
          vecLength = 1;
          var sign = i > j ? 1 : -1;
          vecx = 0.01 * sign;
          vecy = 0.01 * sign;
        }
        // these two nodes overlap
        num si = nodeSizeFunc(nodes[i]);
        num sj = nodeSizeFunc(nodes[j]);
        if (vecLength < si / 2 + sj / 2) {
          var common = (k * k) / vecLength;
          disp[i].x += (vecx / vecLength) * common;
          disp[i].y += (vecy / vecLength) * common;
        }
      }
    }
  }

  void updatePositions() {
    var positions = this.positions;
    var disp = this.disp;
    var speed = this.speed;
    var strictRadial = this.strictRadial;
    int f = focusID;
    var maxDisplace = this.maxDisplace ?? (width / 10);
    if (strictRadial) {
      for (int i = 0; i < disp.length; i++) {
        var di = disp[i];
        var vx = positions[i].x - positions[f].x;
        var vy = positions[i].x - positions[f].x;
        var vLength = sqrt(vx * vx + vy * vy);
        var vpx = vy / vLength;
        var vpy = -vx / vLength;
        var diLength = sqrt(di.x * di.x + di.y * di.y);
        var alpha = acos((vpx * di.x + vpy * di.y) / diLength);
        if (alpha > pi / 2) {
          alpha -= pi / 2;
          vpx *= -1;
          vpy *= -1;
        }
        var tdispLength = cos(alpha) * diLength;
        di.x = vpx * tdispLength;
        di.y = vpy * tdispLength;
      }
    }

    // move
    var radii = this.radii;

    const SPEED_DIVISOR = 800;

    for (int i = 0; i < positions.length; i++) {
      var n = positions[i];
      if (i == f) {
        continue;
      }
      var distLength = sqrt(disp[i].x * disp[i].x + disp[i].y * disp[i].y);
      if (distLength > 0 && i != f) {
        var limitedDist = min(maxDisplace * (speed / SPEED_DIVISOR), distLength);
        n.x += (disp[i].x / distLength) * limitedDist;
        n.y += (disp[i].y / distLength) * limitedDist;
        if (strictRadial) {
          var vx = n.x - positions[f].x;
          var vy = n.y - positions[f].y;
          var nfDis = sqrt(vx * vx + vy * vy);
          vx = (vx / nfDis) * radii[i];
          vy = (vy / nfDis) * radii[i];
          n.x = positions[f].x + vx;
          n.y = positions[f].y + vy;
        }
      }
    }
  }
}
