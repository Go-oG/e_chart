import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ParallelNode extends DataNode<ParallelAttr, ParallelGroup> {
  bool connectNull = true;
  Rect? clipRect;

  ParallelNode(
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var style = borderStyle;
    if (style.notDraw) {
      return;
    }

    var optPath = attr.getPath(style.smooth, connectNull, style.dash);
    var cr = clipRect;
    for (var path in optPath.segmentList) {
      if (cr != null && !path.bound.overlaps(cr)) {
        continue;
      }
      style.drawPath(canvas, paint, path.path, drawDash: false, needSplit: false);
    }
  }

  @override
  void onDrawSymbol(CCanvas canvas, Paint paint) {
    for (var ele in attr.symbolList) {
      var cr = clipRect;
      if (cr != null && !cr.contains2(ele.center)) {
        break;
      }
      ele.onDraw(canvas, paint);
    }
  }

  @override
  void updateStyle(Context context, ParallelSeries series) {
    itemStyle = AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
  }
}

class ParallelAttr {
  final List<SymbolNode> symbolList;
  final int axisCount;
  final num w;
  final num h;
  final Direction direction;

  ParallelAttr(this.symbolList, this.axisCount, this.direction, this.w, this.h);

  num _smooth = 0;
  bool _connectNull = false;
  List<num> _dash = [];

  OptPath? _optPath;
  OptPath? _dashPath;

  OptPath getPath(num smooth, bool connectNull, List<num> dash) {
    if (_optPath != null && smooth == _smooth && connectNull == _connectNull && equalList(_dash, dash)) {
      if (dash.isNotEmpty) {
        return _dashPath!;
      }
      return _optPath!;
    }

    if (_smooth == smooth && connectNull == _connectNull && _optPath != null) {
      _dash = dash;
      if (dash.isEmpty) {
        _dashPath = null;
        return _optPath!;
      }
      return _dashPath = OptPath.not(_optPath!.path.dashPath(dash));
    }

    _smooth = smooth;
    _connectNull = connectNull;
    _dash = dash;

    num dis = 0;
    each(symbolList, (p0, i) {
      if (i < 1) {
        return;
      }
      var pre = symbolList[i - 1].center;
      var cur = symbolList[i].center;
      dis = max([dis, cur.distance2(pre)]);
    });

    var path = _buildPath(smooth, connectNull);

    num len;
    if (dis > 0) {
      len = dis;
    } else {
      len = 2 * (direction == Direction.horizontal ? w : h) / axisCount;
    }
    _optPath = OptPath(path, len);
    if (dash.isNotEmpty) {
      return OptPath.not(path.dashPath(dash));
    }
    return _optPath!;
  }

  Path _buildPath(num smooth, bool connectNull) {
    List<List<Offset>> ol = [];
    if (connectNull) {
      List<Offset> tmp = [];
      for (var symbol in symbolList) {
        tmp.add(symbol.center);
      }
      if (tmp.length >= 2) {
        ol.add(tmp);
      }
    } else {
      List<List<SymbolNode>> sl = splitListForNull(symbolList);
      ol = List.from(sl.map((e) => List.from(e.map((e) => e.center))));
    }

    var path = Path();
    for (var list in ol) {
      if (list.length < 2) {
        continue;
      }
      var first = list.first;
      path.moveTo(first.dx, first.dy);
      if (smooth>0) {
        Line(list, smooth: smooth).appendToPathEnd(path);
      } else {
        for (int i = 1; i < list.length; i++) {
          path.lineTo(list[i].dx, list[i].dy);
        }
      }
    }
    return path;
  }

  bool contains(Offset offset) {
    if (_optPath == null) {
      return false;
    }
    return _optPath!.path.contains(offset);
  }
}
