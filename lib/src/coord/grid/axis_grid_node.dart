import 'dart:math' as m;
import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/src/ext/offset_ext.dart';

import '../../component/index.dart';
import '../../model/index.dart';
import 'axis_grid.dart';
import 'grid_child.dart';

class GridAxisImpl extends LineAxisImpl<GridAxis,LineProps> {
  final Direction direction;
  final List<GridChild> children;

  GridAxisImpl(super.axis, this.children, this.direction);

  void addChild(GridChild child) {
    children.add(child);
  }

  bool get vertical => direction == Direction.vertical;

  ///表示轴的大小
  AxisSize _axisSize = AxisSize(Rect.zero, Offset.zero, Offset.zero, 0);

  AxisSize get axisSize => _axisSize;

  @override
  void measure(double parentWidth, double parentHeight) {
    double length = vertical ? parentHeight : parentWidth;
    double size = 0;
    AxisLine? line = axis.axisLine;
    if (line != null) {
      if (line.show) {
        size += line.style.width;
      }
      if (line.tick != null && line.tick!.show) {
        var mainTick = line.tick!;
        if (mainTick.minorTick != null && mainTick.minorTick!.show) {
          size += m.max(line.tick!.length, mainTick.minorTick!.length);
        } else {
          size += line.tick!.length;
        }
      } else {
        if (line.tick != null && line.tick!.show) {
          size += line.tick!.length;
        }
      }
    }
    AxisLabel? axisLabel = axis.axisLabel;
    if (axisLabel != null) {
      if (axisLabel.show) {
        size += axisLabel.margin;
        var maxStr = getMaxStr();
        Size textSize = axisLabel.labelStyle.measure(maxStr);
        size += (vertical) ? textSize.height : textSize.width;
      }
    }

    Rect rect;
    if (vertical) {
      rect = Rect.fromLTWH(0, 0, size, length);
    } else {
      rect = Rect.fromLTWH(0, 0, length, size);
    }
    _axisSize = AxisSize(rect, rect.topLeft, rect.topRight, length);
  }

  DynamicText getMaxStr() {
    DynamicText maxStr = DynamicText.empty;
    for (var ele in children) {
      List<dynamic> dl = vertical ? ele.yDataSet : ele.xDataSet;
      for (var data in dl) {
        if (data is String) {
          if (data.length > maxStr.length) {
            maxStr = DynamicText(data);
          }
          continue;
        }
        if (data is num) {
          var s = axis.formatFun?.call(data) ?? DynamicText(formatNumber(data));
          if (s.length > maxStr.length) {
            maxStr = s;
          }
          continue;
        }
        if (data is DateTime) {
          var s = axis.timeFormatFun?.call(data) ?? DynamicText(data.toString());
          if (s.length > maxStr.length) {
            maxStr = s;
          }
          continue;
        }
      }
    }
    return maxStr;
  }

  @override
  void layout(LineProps layoutProps, List<DynamicData> dataSet) {
    Rect rect = axisSize.rect;
    if (vertical) {
      rect = Rect.fromLTWH(layoutProps.start.dx, layoutProps.start.dy, rect.width, layoutProps.start.distance2(layoutProps.end));
    } else {
      rect = Rect.fromLTWH(layoutProps.start.dx, layoutProps.start.dy, layoutProps.start.distance2(layoutProps.end), rect.height);
    }
    _axisSize = AxisSize(rect, rect.topLeft, rect.topRight, axisSize.length);
    super.layout(layoutProps, dataSet);
  }

  @override
  BaseScale buildScale(LineProps props, List<DynamicData> dataSet) {
    double distance = 0;
    _axisSize.rect.bottomLeft.distance2(_axisSize.rect.topLeft);
    if (vertical) {
      distance = _axisSize.rect.bottomLeft.distance2(_axisSize.rect.topLeft);
    } else {
      distance = _axisSize.rect.bottomLeft.distance2(_axisSize.rect.bottomRight);
    }
    if (distance.isNaN || distance.isInfinite) {
      distance = double.maxFinite - 1;
    }

    return axis.toScale(0, distance, dataSet);
  }

  ///给定一个数据将其转换为对应维度的坐标
  double dataToPoint(DynamicData data) {
    return 0;
  }
}

class AxisSize {
  final num length;
  final Rect rect;
  final Offset start;
  final Offset end;

  AxisSize(this.rect, this.start, this.end, this.length);
}
