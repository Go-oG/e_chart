import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class BaseGridAxisImpl extends LineAxisImpl<GridAxis, LineAxisAttrs> {
  final GridCoord coord;

  BaseGridAxisImpl(this.coord, super.context, super.axis, {super.axisIndex});

  ///表示轴的大小
  final AxisInfo _axisInfo = AxisInfo(Offset.zero, Offset.zero, Rect.zero);

  AxisInfo get axisInfo => _axisInfo;

  DynamicText getMaxStr(Direction direction) {
    DynamicText maxStr = DynamicText.empty;
    Size size = Size.zero;
    bool isXAxis = direction == Direction.horizontal;
    for (var ele in coord.getGridChildList()) {
      DynamicText text = ele.getAxisMaxText(axisIndex, isXAxis);
      if ((maxStr.isString || maxStr.isTextSpan) && (text.isString || text.isTextSpan)) {
        if (text.length > maxStr.length) {
          maxStr = text;
        }
      } else {
        if (size == Size.zero) {
          size = maxStr.getTextSize();
        }
        Size size2 = text.getTextSize();
        if ((size2.height > size.height && isXAxis) || (!isXAxis && size2.width > size.width)) {
          maxStr = text;
          size = size2;
        }
      }
    }
    return maxStr;
  }
}
