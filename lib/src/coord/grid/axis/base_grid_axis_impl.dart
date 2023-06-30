import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import 'axis_size.dart';

abstract class BaseGridAxisImpl extends LineAxisImpl<GridAxis, LineProps> {
  final List<GridChild> children = [];

  BaseGridAxisImpl(super.axis);

  void addChild(GridChild child) {
    children.add(child);
  }

  ///表示轴的大小
  final AxisInfo _axisInfo = AxisInfo(Direction.vertical, Offset.zero, Offset.zero, Rect.zero);

  AxisInfo get axisInfo => _axisInfo;

  List<num> dataToPoint(DynamicData data) {
    return scale.toRange(data.data);
  }

  DynamicText getMaxStr(Direction direction) {
    DynamicText maxStr = DynamicText.empty;
    for (var ele in children) {
      List<dynamic> dl = direction == Direction.horizontal ? ele.xDataSet : ele.yDataSet;
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
}
