import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';


class HexagonsLayout extends HexbinLayout {
  int ringStartIndex;
  bool clockwise;

  HexagonsLayout({
    this.ringStartIndex = 4,
    this.clockwise = true,
    super.center,
    super.flat,
    super.radius,
  }) {
    if (ringStartIndex < 0 || ringStartIndex >= 6) {
      throw FlutterError('ringStartIndex must  >= 0 && < 6');
    }
  }

  @override
  void onLayout2(List<HexbinNode> data, LayoutType type) {
    int level = computeMinLevel(data.length);
    List<Hex> hexList = hexagons(level);
    each(data, (node, i) {
      node.attr.hex = hexList[i];
    });
  }

  ///计算将给定count数的节点放置完需要的最小层数
  ///例如等差数列前 N项和公式 和 一元二次方程求根公式计算
  int computeMinLevel(int nodeCount) {
    int c = -nodeCount;
    int a = 3;
    int b = -2;
    int x1 = ((-b + m.sqrt(4 - 4 * a * c)) / 6).round();
    int x2 = ((-b - m.sqrt(4 - 4 * a * c)) / 6).round();
    if (x1 < 0 && x2 < 0) {
      throw FlutterError('计算异常');
    }
    if (x1 > 0 && (3 * x1 * x1 - 2 * x1) >= nodeCount) {
      return x1;
    }
    if (x2 > 0 && (3 * x2 * x2 - 2 * x2) >= nodeCount) {
      return x2;
    }
    return m.max(x1.abs(), x2.abs()) + 1;
  }

  /// 蜂窝环绕
  List<Hex> hexagons(int level) {
    List<Hex> hexList = [];
    Hex centerHex = Hex(0, 0, 0);
    hexList.add(centerHex);
    for (int k = 1; k <= level; k++) {
      hexList.addAll(HexbinLayout.ring(centerHex, k, ringStartIndex, clockwise));
    }
    return hexList;
  }
}
