//漏斗图布局计算相关
import 'package:flutter/material.dart';

import '../../animation/tween/offset_tween.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import '../../model/enums/sort.dart';
import '../../model/group_data.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import 'funnel_series.dart';

class FunnelLayers {
  final double gap;
  final Direction direction;
  final Sort sort;
  final Align2 align;

  FunnelLayers(this.gap, this.direction, this.sort, this.align);

  List<FunnelNode> layout(double width, double height, List<ItemData> list, {double? maxValue}) {
    if (list.isEmpty) {
      return [];
    }
    sortData(list);

    num max = list.first.value;
    List<FunnelNode> nodeList = [];
    for (int i = 0; i < list.length; i++) {
      var element = list[i];
      int index;
      if (sort == Sort.asc) {
        index = i - 1;
      } else {
        index = i + 1;
      }
      ItemData? preData;
      if (index >= 0 && index < list.length) {
        preData = list[index];
      }
      nodeList.add(FunnelNode(preData, element));
      preData = element;
      if (element.value > max) {
        max = element.value;
      }
    }
    if (maxValue != null && max < maxValue) {
      max = maxValue;
    }

    if (direction == Direction.vertical) {
      _layoutVertical(width, height, nodeList);
    } else {
      _layoutHorizontal(width, height, nodeList);
    }
    for (var element in nodeList) {
      element._computePoint(align, direction, sort, max, gap);
    }
    return nodeList;
  }

  void sortData(List<ItemData> list) {
    list.sort((a, b) {
      if (sort == Sort.asc) {
        return a.value.compareTo(b.value);
      } else {
        return b.value.compareTo(a.value);
      }
    });
  }

  void _layoutVertical(double width, double height, List<FunnelNode> nodeList) {
    int count = nodeList.length;
    double gapAllHeight = (count - 1) * gap;
    double itemHeight = (height - gapAllHeight) / count;
    double offsetY = 0;
    for (var node in nodeList) {
      node.left = 0;
      node.right = width;
      node.top = offsetY;
      node.bottom = node.top + itemHeight;
      offsetY += itemHeight + gap;
    }
  }

  void _layoutHorizontal(double width, double height, List<FunnelNode> nodeList) {
    int count = nodeList.length;
    double gapAllWidth = (count - 1) * gap;
    double itemWidth = (width - gapAllWidth) / count;
    double offsetX = 0;
    for (var node in nodeList) {
      node.top = 0;
      node.bottom = height;
      node.left = offsetX;
      node.right = offsetX + itemWidth;
      offsetX += itemWidth + gap;
    }
  }
}

class FunnelNode {
  final ItemData? preData;
  final ItemData data;

  ///标识顶点坐标
  ///leftTop:[0];rightTop:[1];rightBottom:[2]; leftBottom:[3];
  final List<Offset> _pointList = [];

  double top = 0;
  double right = 0;
  double left = 0;
  double bottom = 0;

  FunnelNode(this.preData, this.data);

  double animatorPercent = 1;
  double textScaleFactor = 1;

  Path? _path;

  Path get path {
    if (_path != null) {
      return _path!;
    }
    _path = Path();
    if (_pointList.isNotEmpty) {
      _path!.moveTo(_pointList[0].dx, _pointList[0].dy);
      for (Offset offset in _pointList) {
        _path!.lineTo(offset.dx, offset.dy);
      }
    }
    _path!.close();
    return _path!;
  }

  List<Offset> get pointList => _pointList;

  void _computePoint(Align2 align, Direction direction, Sort sort, num maxData, double gap) {
    double width = right - left;
    double height = bottom - top;
    double percent = data.value / maxData;

    Align2 align2 = align;

    /// horizontal
    if (direction == Direction.horizontal) {
      double h = height * percent;
      double preH;
      if (preData == null) {
        preH = 0;
      } else {
        preH = height * (preData!.value / maxData);
      }
      if (preH != 0) {
        h -= gap;
      }
      if (sort == Sort.asc) {
        if (align2 == Align2.start) {
          _pointList.add(Offset(left, top));
          _pointList.add(Offset(right, top));
          _pointList.add(Offset(right, top + h));
          _pointList.add(Offset(left, top + preH));
          return;
        }
        if (align2 == Align2.center) {
          double centerY = (top + bottom) / 2.0;
          _pointList.add(Offset(left, centerY - preH / 2));
          _pointList.add(Offset(right, centerY - h / 2));
          _pointList.add(Offset(right, centerY + h / 2));
          _pointList.add(Offset(left, centerY + preH / 2));
          return;
        }
        if (align2 == Align2.end) {
          _pointList.add(Offset(left, bottom - preH));
          _pointList.add(Offset(right, bottom - h));
          _pointList.add(Offset(right, bottom));
          _pointList.add(Offset(left, bottom));
        }
        return;
      }

      // sortDesc
      if (align2 == Align2.start) {
        _pointList.add(Offset(left, top));
        _pointList.add(Offset(right, top));
        _pointList.add(Offset(right, top + preH));
        _pointList.add(Offset(left, top + h));
        return;
      }
      if (align2 == Align2.center) {
        double centerY = (top + bottom) / 2.0;
        _pointList.add(Offset(left, centerY - h / 2));
        _pointList.add(Offset(right, centerY - preH / 2));
        _pointList.add(Offset(right, centerY + preH / 2));
        _pointList.add(Offset(left, centerY + h / 2));
        return;
      }
      if (align2 == Align2.end) {
        _pointList.add(Offset(left, bottom - h));
        _pointList.add(Offset(right, bottom - preH));
        _pointList.add(Offset(right, bottom));
        _pointList.add(Offset(left, bottom));
      }
      return;
    }

    /// vertical
    double w = width * percent;
    double preW;
    if (preData == null) {
      preW = 0;
    } else {
      preW = width * (preData!.value / maxData);
    }
    if (preW != 0) {
      w -= gap;
    }

    /// asc
    if (sort == Sort.asc) {
      if (align2 == Align2.start) {
        _pointList.add(Offset(left, top));
        _pointList.add(Offset(left + preW, top));
        _pointList.add(Offset(left + w, bottom));
        _pointList.add(Offset(left, bottom));
        return;
      }
      if (align2 == Align2.center) {
        double centerX = (right + left) / 2.0;

        _pointList.add(Offset(centerX - preW / 2, top));
        _pointList.add(Offset(centerX + preW / 2, top));
        _pointList.add(Offset(centerX + w / 2, bottom));
        _pointList.add(Offset(centerX - w / 2, bottom));
        return;
      }
      if (align2 == Align2.end) {
        _pointList.add(Offset(right - preW, top));
        _pointList.add(Offset(right, top));
        _pointList.add(Offset(right, bottom));
        _pointList.add(Offset(right - w, bottom));
      }
      return;
    }

    /// desc
    if (align2 == Align2.start) {
      _pointList.add(Offset(left, top));
      _pointList.add(Offset(left + w, top));
      _pointList.add(Offset(left + preW, bottom));
      _pointList.add(Offset(left, bottom));
      return;
    }
    if (align2 == Align2.center) {
      double centerX = (right + left) / 2.0;
      _pointList.add(Offset(centerX - w / 2, top));
      _pointList.add(Offset(centerX + w / 2, top));
      _pointList.add(Offset(centerX + preW / 2, bottom));
      _pointList.add(Offset(centerX - preW / 2, bottom));
      return;
    }
    if (align2 == Align2.end) {
      _pointList.add(Offset(right - w, top));
      _pointList.add(Offset(right, top));
      _pointList.add(Offset(right, bottom));
      _pointList.add(Offset(right - preW, bottom));
    }
  }

  @override
  String toString() {
    String s = '';
    for (var element in _pointList) {
      s = '$s$element ';
    }

    return 'left:$left top:$top right:$right bottom:$bottom $s';
  }

  TextDrawConfig? computeTextPosition(FunnelSeries series) {
    LabelStyle? style = series.labelStyleFun?.call(data, null);
    if (style == null || !style.show) {
      return null;
    }
    bool vertical = series.direction == Direction.vertical;
    double lineWidth = style.lineMargin + style.guideLine.length;
    Offset p0 = pointList[0];
    Offset p1 = pointList[1];
    Offset p2 = pointList[2];
    Offset p3 = pointList[3];
    FunnelAlign align = series.labelAlign;

    Offset offset;
    if (align == FunnelAlign.left) {
      if (series.direction == Direction.horizontal) {
        offset = Offset(p0.dx, (p0.dy + p3.dy) / 2);
        return TextDrawConfig(offset, align: Alignment.centerLeft);
      }
      offset = Offset((p0.dx + p3.dx) / 2, (p0.dy + p3.dy) / 2);
      offset = offset.translate(-lineWidth, 0);
      return TextDrawConfig(offset, align: Alignment.centerRight);
    }
    if (align == FunnelAlign.top) {
      if (series.direction == Direction.vertical) {
        offset = Offset((p0.dx + p1.dx) / 2, p0.dy);
        return TextDrawConfig(offset, align: Alignment.topCenter);
      }
      offset = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      offset = offset.translate(0, -lineWidth);
      return TextDrawConfig(offset, align: Alignment.bottomCenter);
    }
    if (align == FunnelAlign.right) {
      if (series.direction == Direction.horizontal) {
        offset = Offset(p2.dx, (p1.dy + p2.dy) / 2);
        return TextDrawConfig(offset, align: Alignment.centerRight);
      }

      offset = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      offset = offset.translate(lineWidth, 0);
      return TextDrawConfig(offset, align: Alignment.centerLeft);
    }
    if (align == FunnelAlign.bottom) {
      if (series.direction == Direction.vertical) {
        offset = Offset((p0.dx + p1.dx) / 2, p2.dy);
        return TextDrawConfig(offset, align: Alignment.bottomCenter);
      }

      offset = Offset((p2.dx + p3.dx) / 2, (p2.dy + p3.dy) / 2);
      offset = offset.translate(0, lineWidth);
      return TextDrawConfig(offset, align: Alignment.topCenter);
    }
    if (align == FunnelAlign.center) {
      offset = Offset((p0.dx + p1.dx) / 2, (p0.dy + p3.dy) / 2);
      return TextDrawConfig(offset, align: Alignment.center);
    }
    if (align == FunnelAlign.insideLeft) {
      offset = Offset((p0.dx + p3.dx) / 2, (p0.dy + p3.dy) / 2);
      return TextDrawConfig(offset, align: Alignment.centerLeft);
    }
    if (align == FunnelAlign.insideRight) {
      offset = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      return TextDrawConfig(offset, align: Alignment.centerRight);
    }
    if (align == FunnelAlign.insideTop) {
      offset = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      return TextDrawConfig(offset, align: Alignment.topCenter);
    }
    if (align == FunnelAlign.insideBottom) {
      offset = Offset((p2.dx + p3.dx) / 2, (p2.dy + p3.dy) / 2);
      return TextDrawConfig(offset, align: Alignment.bottomCenter);
    }
    if (align == FunnelAlign.leftTop) {
      offset = p0;
      Alignment mode;
      if (vertical) {
        offset = offset.translate(-lineWidth, 0);
        mode = Alignment.centerRight;
      } else {
        offset = offset.translate(0, -lineWidth);
        mode = Alignment.bottomCenter;
      }
      return TextDrawConfig(offset, align: mode);
    }
    if (align == FunnelAlign.leftBottom) {
      offset = p3;
      Alignment mode;
      if (vertical) {
        offset = offset.translate(-lineWidth, 0);
        mode = Alignment.centerRight;
      } else {
        offset = offset.translate(0, lineWidth);
        mode = Alignment.topCenter;
      }
      return TextDrawConfig(offset, align: mode);
    }
    if (align == FunnelAlign.rightTop) {
      offset = p1;
      Alignment mode;
      if (vertical) {
        offset = offset.translate(lineWidth, 0);
        mode = Alignment.centerLeft;
      } else {
        offset = offset.translate(0, -lineWidth);
        mode = Alignment.bottomCenter;
      }
      return TextDrawConfig(offset, align: mode);
    }
    if (align == FunnelAlign.rightBottom) {
      offset = p2;
      Alignment mode;
      if (vertical) {
        offset = offset.translate(lineWidth, 0);
        mode = Alignment.centerLeft;
      } else {
        offset = offset.translate(0, lineWidth);
        mode = Alignment.topCenter;
      }
      return TextDrawConfig(offset, align: mode);
    }
    return null;
  }

  List<Offset>? computeLabelLineOffset(FunnelSeries series) {
    List<Offset>? list = _computeLabelLineOffsetInner(series);
    if (list == null) {
      return list;
    }
    OffsetTween tween = OffsetTween(list[0], list[1]);
    return [list[0], tween.safeGetValue(animatorPercent)];
  }

  List<Offset>? _computeLabelLineOffsetInner(FunnelSeries series) {
    LabelStyle? style = series.labelStyleFun?.call(data, null);
    if (style == null || !style.show) {
      return null;
    }
    bool vertical = series.direction == Direction.vertical;
    double lineWidth = style.guideLine.length.toDouble();
    Offset p0 = pointList[0];
    Offset p1 = pointList[1];
    Offset p2 = pointList[2];
    Offset p3 = pointList[3];
    FunnelAlign align = series.labelAlign;
    if (series.direction == Direction.horizontal) {
      if (align == FunnelAlign.left || align == FunnelAlign.right) {
        return null;
      }
    } else {
      if (align == FunnelAlign.top || align == FunnelAlign.bottom) {
        return null;
      }
    }

    if (align == FunnelAlign.top) {
      Offset offset = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      return [offset, offset.translate(0, -lineWidth)];
    }
    if (align == FunnelAlign.left) {
      Offset offset = Offset((p0.dx + p3.dx) / 2, (p0.dy + p3.dy) / 2);
      return [offset, offset.translate(-lineWidth, 0)];
    }
    if (align == FunnelAlign.right) {
      Offset offset = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      return [offset, offset.translate(lineWidth, 0)];
    }
    if (align == FunnelAlign.bottom) {
      Offset offset = Offset((p2.dx + p3.dx) / 2, (p2.dy + p3.dy) / 2);
      return [offset, offset.translate(0, lineWidth)];
    }
    if (align == FunnelAlign.leftTop) {
      Offset offset = p0;
      if (vertical) {
        return [offset, offset.translate(lineWidth, 0)];
      } else {
        return [offset, offset.translate(0, -lineWidth)];
      }
    }
    if (align == FunnelAlign.leftBottom) {
      Offset offset = p3;
      if (vertical) {
        return [offset, offset.translate(-lineWidth, 0)];
      } else {
        return [offset, offset.translate(0, lineWidth)];
      }
    }
    if (align == FunnelAlign.rightTop) {
      Offset offset = p1;
      if (vertical) {
        return [offset, offset.translate(lineWidth, 0)];
      } else {
        return [offset, offset.translate(0, -lineWidth)];
      }
    }
    if (align == FunnelAlign.rightBottom) {
      Offset offset = p2;
      if (vertical) {
        return [offset, offset.translate(lineWidth, 0)];
      } else {
        return [offset, offset.translate(0, lineWidth)];
      }
    }
    return null;
  }
}
