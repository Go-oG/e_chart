import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TreeData extends ChartTree<TreeAttr, TreeData> {
  static final TreeData empty = TreeData(null, []);

  TreeData(super.parent, super.children, {super.id, super.value});

  @override
  String toString() {
    return '$x:${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}';
  }

  @override
  bool contains(Offset offset) {
    return attr.symbol.contains(center, offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    Offset offset = center;
    if (offset.dx.isNaN || offset.dy.isNaN) {
      return;
    }
    attr.symbol.draw(canvas, paint, offset);
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant TreeSeries series) {
    attr.symbol = series.getSymbol(context, this);
    label.updatePainter(style: series.getLabelStyle(context, this));
  }

  @override
  TreeAttr initAttr()=>TreeAttr(EmptySymbol.empty);
}

class TreeAttr {
  ChartSymbol symbol;

  TreeAttr(this.symbol);

  TreeAttr.of() : symbol = EmptySymbol();
}
