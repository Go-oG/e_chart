import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///该节点的存在是为了优化折线图在大数据量下的绘制
class LineNode<T extends StackItemData, P extends StackGroupData<T, P>> {
  final StackData<T, P> data;
  final Path? path;
  final Path? areaPath;
  final ChartSymbol? symbol;

  LineNode(
    this.data,
    this.path,
    this.areaPath,
    this.symbol,
  );
}
