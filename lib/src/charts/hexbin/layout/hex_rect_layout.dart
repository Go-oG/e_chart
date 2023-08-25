import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import '../hex.dart';
import '../hex_bin_helper.dart';

///矩形布局
///建议将 [rowPriority] 和[flat] 设置为不同的值
class HexRectLayout extends HexbinLayout {
  ///是否为行优先
  bool rowPriority;

  ///是否偶数行缩进
  bool evenLineIndent;

  ///每行或者没列最大值
  int? maxCount;
  int? minCount;

  int row = 0;
  int col = 0;

  HexRectLayout(
      {this.rowPriority = false,
      this.evenLineIndent = true,
      this.maxCount,
      this.minCount,
      super.center = const [SNumber.zero, SNumber.zero],
      super.flat = true,
      super.radius});

  @override
  void onLayout2(List<HexbinNode> data, LayoutType type) {
    List<int> tl = computeRowAndCol(data.length, width, height, radius);
    row = tl[0];
    col = tl[1];
    int left = 0, top = 0, right = col, bottom = row;
    List<Hex> hexList = [];
    if (rowPriority) {
      for (int i = top; i < bottom; i++) {
        for (int j = left; j < right; j++) {
          hexList.add(HexbinLayout.offsetCoordToHexCoord(i, j, flat: flat, evenLineIndent: evenLineIndent));
        }
      }
    } else {
      for (int i = left; i < right; i++) {
        for (int j = top; j < bottom; j++) {
          hexList.add(HexbinLayout.offsetCoordToHexCoord(j, i, flat: flat, evenLineIndent: evenLineIndent));
        }
      }
    }
    each(data, (node, i) {
      node.attr.hex = hexList[i];
    });
  }

  ///该方法在onLayout之后执行
  @override
  Offset computeZeroCenter(HexbinSeries series, num width, num height) {
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    num w, h;
    if (flat) {
      if (col % 2 != 0) {
        w =radius*(col-1)*2;
      } else {
        w = 2.5 * radius * (col ~/ 2);
      }
      h=row*sqrt(3)*radius+radius;
    } else {
      w=sqrt(3)*radius*col+radius*(row>=1?1:0);
      h=row*2*radius+radius;
    }

    return Offset(x-w/2, y-h/2);
  }

  List<int> computeRowAndCol(int nodeCount, num width, num height, num radius) {
    int row;
    int col;
    num d = flat ? radius * 2 : radius * sqrt(3);
    if (rowPriority) {
      //行优先
      col = width ~/ d;
      if (minCount != null && col < minCount!) {
        col = minCount!;
      }
      if (maxCount != null && col > maxCount!) {
        col = maxCount!;
      }
      row = nodeCount ~/ col;
      if (col * row < nodeCount) {
        row++;
      }
    } else {
      //列优先
      row = height ~/ d;
      if (minCount != null && row < minCount!) {
        row = minCount!;
      }
      if (maxCount != null && row > maxCount!) {
        row = maxCount!;
      }
      col = nodeCount ~/ row;
      if (col * row < nodeCount) {
        col++;
      }
    }
    return [row, col];
  }
}
