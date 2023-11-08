import 'dart:math';

import 'package:e_chart/e_chart.dart';


///平行四边形布局
class HexParallelLayout extends HexbinLayout {
  static const int typeQR = 0;
  static const int typeSQ = 1;
  static const int typeRS = 2;

  int type = 0;
  int row = 0;
  int col = 0;

  HexParallelLayout({this.type = 0});

  @override
  void onLayout(List<HexBinData> data, LayoutType type,HexbinLayoutParams params) {
    row = computeRow(data.length);
    col=data.length~/row;
    if(row*col<data.length){
      col+=1;
    }
    int s = -row ~/ 2;
    int e = row ~/ 2;
    if (s + e != 0) {
      if (s.abs() > row ~/ 2) {
        s += 1;
      } else {
        e += 1;
      }
    }

    Pair<int> p = Pair(s, e);
    List<Hex> hexList = parallelograms(p, p);
    each(data, (node, i) {
      node.hex=hexList[i];
    });
  }

  int computeRow(int nodeSize) {
    int sq = sqrt(nodeSize).floor();
    if (sq * sq >= nodeSize) {
      return sq;
    }
    return sq + 1;
  }

  ///平行四边形
  List<Hex> parallelograms(Pair<int> p1, Pair<int> p2) {
    List<Hex> hexList = [];
    for (int i = p1.start; i <= p1.end; i++) {
      for (int j = p2.start; j <= p2.end; j++) {
        if (type == typeQR) {
          hexList.add(Hex(i, j, -i - j));
        } else if (type == typeSQ) {
          hexList.add(Hex(j, -i - j, i));
        } else {
          hexList.add(Hex(-i - j, i, j));
        }
      }
    }
    return hexList;
  }
}
