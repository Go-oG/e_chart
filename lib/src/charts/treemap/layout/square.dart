import 'dart:math' as m;
import 'dart:ui';
import 'package:e_chart/e_chart.dart';

double phi = (1 + m.sqrt(5)) / 2;

class SquareLayout extends TreemapLayout {
  num ratio = phi;

  @override
  void onLayout2(TreeMapNode root, LayoutType type) {
    root.children.sort((a, b) {
      return b.value.compareTo(a.value);
    });
    Rect rect = boxBound;
    layoutChildren(ratio, root, rect.left, rect.top, rect.right, rect.bottom);
  }

  static List<Row> layoutChildren(num ratio, TreeMapNode parent, double left, double top, double right, double bottom) {
    List<Row> rows = [];
    List<TreeMapNode> nodes = parent.children;
    num value = parent.value;

    num minValue;
    num maxValue;
    double newRatio;
    double minRatio;
    double alpha;
    double beta;

    int i0 = 0;
    int i1 = 0;
    int n = nodes.length;
    num nodeValue;
    double dx;
    double dy;
    num sumValue;
    while (i0 < n) {
      dx = right - left;
      dy = bottom - top;
      // 找到下一个非空的数据
      do {
        sumValue = nodes[i1++].value;
      } while (sumValue == 0 && i1 < n);

      minValue = maxValue = sumValue;

      alpha = m.max(dy / dx, dx / dy) / (value * ratio);
      beta = sumValue * sumValue * alpha;
      minRatio = m.max(maxValue / beta, beta / minValue);
      // 保持纵横比的同时继续添加节点
      for (; i1 < n; ++i1) {
        nodeValue = nodes[i1].value;
        sumValue += nodeValue;

        if (nodeValue < minValue) {
          minValue = nodeValue;
        }
        if (nodeValue > maxValue) {
          maxValue = nodeValue;
        }
        beta = sumValue * sumValue * alpha;
        newRatio = m.max(maxValue / beta, beta / minValue);
        if (newRatio > minRatio) {
          sumValue -= nodeValue;
          break;
        }
        minRatio = newRatio;
      }
      // 定位并记录行方向
      Row row = Row(sumValue, dx < dy, nodes.sublist(i0, i1));
      rows.add(row);
      if (row.dice) {
        treemapDice(row, left, top, right, isTrue(value) ? (top += (dy * sumValue / value)) : bottom);
      } else {
        treemapSlice(row, left, top, isTrue(value) ? left += (dx * sumValue / value) : right, bottom);
      }
      value -= sumValue;
      i0 = i1;
    }
    return rows;
  }

  static void treemapSlice(Row parent, double x0, double y0, double x1, double y1) {
    SliceLayout.layoutChildren(Rect.fromLTRB(x0, y0, x1, y1), parent.children);
  }

  static void treemapDice(Row parent, double x0, double y0, double x1, double y1) {
    DiceLayout.layoutChildren(Rect.fromLTRB(x0, y0, x1, y1), parent.children);
  }
}

class Row {
  num value;
  bool dice;
  List<TreeMapNode> children;

  Row(this.value, this.dice, this.children);
}
