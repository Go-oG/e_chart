import 'dart:math' as m;
import 'dart:ui';

import 'package:xchart/src/component/axis/axis_line.dart';
import 'package:xchart/src/component/axis/impl/line_axis_impl.dart';
import 'package:xchart/src/ext/offset_ext.dart';
import 'package:xchart/src/model/enums/direction.dart';
import 'package:xutil/xutil.dart';

import '../../component/scale/scale_base.dart';
import '../../model/dynamic_data.dart';
import 'axis_grid.dart';
import 'grid_child.dart';

class GridAxisImpl extends LineAxisImpl<GridAxis> {
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
    AxisLine line = axis.axisLine;
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
    if (axis.axisLabel.show) {
      size += axis.axisLabel.margin;
      var maxStr = getMaxStr();
      Size textSize = axis.axisLabel.labelStyle.measure(maxStr);
      size += (vertical) ? textSize.height : textSize.width;
    }
    Rect rect;
    if (vertical) {
      rect = Rect.fromLTWH(0, 0, size, length);
    } else {
      rect = Rect.fromLTWH(0, 0, length, size);
    }
    _axisSize = AxisSize(rect, rect.topLeft, rect.topRight, length);
  }

  String getMaxStr() {
    var maxStr = '';
    for (var ele in children) {
      List<dynamic> dl = vertical ? ele.yDataSet : ele.xDataSet;
      for (var data in dl) {
        if (data is String) {
          if (data.length > maxStr.length) {
            maxStr = data;
          }
          continue;
        }
        if (data is num) {
          var s = axis.formatFun?.call(data) ?? formatNumber(data);
          if (s.length > maxStr.length) {
            maxStr = s;
          }
          continue;
        }
        if (data is DateTime) {
          var s = axis.timeFormatFun?.call(data) ?? (data.toString());
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
    if (vertical) {
      return axis.toScale(0, _axisSize.rect.bottomLeft.distance2(_axisSize.rect.topLeft), dataSet);
    }
    return axis.toScale(0, _axisSize.rect.bottomLeft.distance2(_axisSize.rect.bottomRight), dataSet);
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
