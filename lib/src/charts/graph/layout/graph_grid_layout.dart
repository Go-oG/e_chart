import 'dart:math' as m;
import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart';

///网格布局
class GraphGridLayout extends GraphLayout {
  ///左上角开始位置
  List<SNumber> begin;

  ///为true时最大化占用画布空间
  bool fullCanvas;

  ///指定行列数
  int? rows;
  int? cols;

  ///是否防止重叠(当为true时，才会使用nodeSize进行碰撞检查)
  bool preventOverlap;

  ///位置函数(可用于固定位置)
  Fun4<GraphNode, int, int, m.Point<int>?>? positionFun;

  GraphGridLayout({
    this.rows,
    this.cols,
    this.begin = const [SNumber.number(0), SNumber.number(0)],
    this.fullCanvas = true,
    this.preventOverlap = false,
    super.nodeSize,
    super.sizeFun,
    super.nodeSpaceFun,
    super.sort,
    super.workerThread,
  });

  ///============布局使用的数值======

  @override
  void onLayout(LayoutType type) {
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
    int nodeCount = graph.nodes.length;
    if (nodeCount == 0) {
      notifyLayoutEnd();
      return;
    }
    LayoutProps props = LayoutProps();
    props.begin = Offset(begin[0].convert(width), begin[1].convert(height));
    if (nodeCount == 1) {
      graph.nodes[0].x = props.begin.dx;
      graph.nodes[0].y = props.begin.dy;
      notifyLayoutEnd();
      return;
    }

    List<GraphNode> layoutNodes = [...graph.nodes];

    ///排序
    sortNode(graph, layoutNodes);

    ///计算 实际的行列数并赋值
    computeRowAndCol(props, nodeCount, width, height);

    if (props.rows <= 0 || props.cols <= 0) {
      throw FlutterError('内部异常 行列计算值<=0');
    }

    ///修正 row col
    if (props.cols * props.rows > props.cells) {
      int sm = small(props, null)!;
      int lg = large(props, null)!;
      if ((sm - 1) * lg >= props.cells) {
        small(props, sm - 1);
      } else if ((lg - 1) * sm >= props.cells) {
        large(props, lg - 1);
      }
    } else {
      while (props.cols * props.rows < props.cells) {
        checkInterrupt();
        int sm = small(props, null)!;
        int lg = large(props, null)!;
        if ((lg + 1) * sm >= props.cells) {
          large(props, lg + 1);
        } else {
          small(props, sm + 1);
        }
      }
    }

    ///计算单元格大小
    props.cellWidth = width / props.cols;
    props.cellHeight = height / props.rows;
    if (!fullCanvas) {
      props.cellWidth = 0;
      props.cellHeight = 0;
    }

    // 防重叠处理(重新计算格子宽度)
    if (preventOverlap || nodeSpaceFun != null) {
      Fun2<GraphNode, num> spaceFun = nodeSpaceFun ?? (a) => 10;
      for (var node in layoutNodes) {
        checkInterrupt();
        Size res = getNodeSize(node);
        num nodeW;
        num nodeH;
        nodeW = res.width;
        nodeH = res.height;
        num p = spaceFun.call(node);
        var w = nodeW + p;
        var h = nodeH + p;
        props.cellWidth = m.max(props.cellWidth, w);
        props.cellHeight = m.max(props.cellHeight, h);
      }
    }

    props.rowIndex = 0;
    props.colIndex = 0;
    props.id2manPos = {};

    for (var node in layoutNodes) {
      checkInterrupt();
      m.Point<int>? rcPos;

      ///固定位置处理
      if (positionFun != null) {
        rcPos = positionFun!.call(node, props.rows, props.cols);
      }
      if (rcPos != null) {
        InnerPos pos = InnerPos(rcPos.x, rcPos.y);
        props.id2manPos[node.id] = pos;
        _setUsed(props, pos.row, pos.col);
      }
      computePosition(props, node);
    }
    notifyLayoutEnd();
  }

  @override
  void stopLayout() {
    super.stopLayout();
    interrupt();
  }

  int? small(LayoutProps props, int? val) {
    int? res;
    int rows = jsOr(props.rows, 5);
    int cols = jsOr(props.cols, 5);
    if (val == null) {
      res = m.min(rows, cols);
    } else {
      var minV = m.min(rows, cols);
      if (minV == props.rows) {
        props.rows = val;
      } else {
        props.cols = val;
      }
    }
    return res;
  }

  int? large(LayoutProps props, int? val) {
    int? res;
    int rows = jsOr(props.rows, 5);
    int cols = jsOr(props.cols, 5);
    if (val == null) {
      res = m.max(rows, cols);
    } else {
      var maxV = m.max(rows, cols);
      if (maxV == props.rows) {
        props.rows = val.toInt();
      } else {
        props.cols = val.toInt();
      }
    }
    return res;
  }

  bool _hasUsed(LayoutProps props, int? row, int? col) {
    return isTrue(jsOr(props.cellUsed['c-$row-$col'], false));
  }

  void _setUsed(LayoutProps props, int row, int col) {
    props.cellUsed['c-$row-$col'] = true;
  }

  void moveToNextCell(LayoutProps props) {
    var cols = jsOr(props.cols, 5);
    props.colIndex += 1;
    if (props.colIndex >= cols) {
      props.colIndex = 0;
      props.rowIndex += 1;
    }
  }

  void computePosition(LayoutProps props, GraphNode node) {
    num x;
    num y;
    var rcPos = props.id2manPos[node.id];
    if (rcPos != null) {
      x = rcPos.col * props.cellWidth + props.cellWidth / 2 + props.begin.dx;
      y = rcPos.row * props.cellHeight + props.cellHeight / 2 + props.begin.dy;
    } else {
      while (_hasUsed(props, props.rowIndex, props.colIndex)) {
        moveToNextCell(props);
      }
      x = props.colIndex * props.cellWidth + props.cellWidth / 2 + props.begin.dx;
      y = props.rowIndex * props.cellHeight + props.cellHeight / 2 + props.begin.dy;
      _setUsed(props, props.rowIndex, props.colIndex);
      moveToNextCell(props);
    }
    node.x = x.toDouble();
    node.y = y.toDouble();
  }

  ///计算行 列数
  void computeRowAndCol(LayoutProps props, int nodeCount, num width, num height) {
    int? oRows = rows;
    int? oCols = cols;
    props.cells = nodeCount;

    if (oRows != null && oRows > 0 && oCols != null && oCols > 0) {
      props.rows = oRows;
      props.cols = oCols;
    } else if (oRows != null && oRows > 0 && (oCols == null || oCols <= 0)) {
      props.rows = oRows;
      props.cols = (props.cells / rows!).ceil();
    } else if ((oRows == null || oRows <= 0) && oCols != null && oCols > 0) {
      props.cols = oCols;
      props.rows = (props.cells / cols!).ceil();
    } else {
      props.splits = m.sqrt((props.cells * height) / width);
      rows = props.splits.round();
      cols = ((width / height) * props.splits).round();
    }
    props.rows = m.max(props.rows, 1);
    props.cols = m.max(props.cols, 1);
  }
}

class InnerPos {
  final int row;
  final int col;

  InnerPos(this.row, this.col);
}

class LayoutProps {
  Offset begin = Offset.zero;

  ///记录实际的row 和行数
  int rows = 0;
  int cols = 0;
  num cells = 0;

  //单元格的大小
  num cellWidth = 0;
  num cellHeight = 0;

  ///记录当前访问的行和列索引
  int rowIndex = 0;
  int colIndex = 0;

  ///分割数
  late num splits;

  ///存放已经使用的单元格
  Map<String, bool> cellUsed = {};

  ///存放位置映射
  Map<String, InnerPos> id2manPos = {};
}
