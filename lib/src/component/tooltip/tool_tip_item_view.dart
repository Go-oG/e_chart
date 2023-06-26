import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/material.dart';

import '../../core/view.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import 'context_menu.dart';

class ToolTipItemView extends  ChartView {
  final MenuItem item;
  ToolTipItemView(this.item);
  Size? _subSize;
  final LabelStyle _defaultSubStyle = const LabelStyle(textStyle: TextStyle(color: Colors.black87, fontSize: 13));

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size symbolSize = item.symbol?.size ?? Size.zero;
    num textHeight = 0;
    num textWidth = 0;

    Size s = item.textStyle.measure(item.text);
    textWidth += s.width;
    textHeight += s.height;

    num subH = 0;
    num subW = 0;
    _subSize = null;
    if (item.subText != null && item.subText!.isNotEmpty) {
      Size s2 = (item.subTextStyle ?? _defaultSubStyle).measure(item.subText!);
      subH = s2.height;
      subW = s2.width;
      _subSize = s2;
    }

    num w = symbolSize.width + textWidth + subW;
    num h = max([textHeight, subH, symbolSize.height]);

    if (symbolSize.width > 0) {
      w += 8;
    }

    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onDraw(Canvas canvas) {
    double c = height / 2;
    double left = 0;
    if (item.symbol != null) {
      Size s = item.symbol!.size;
      item.symbol?.draw(canvas, mPaint, Offset(s.width / 2, c),1);
      left += s.width + 8;
    }
    item.textStyle.draw(canvas, mPaint, item.text, TextDrawConfig(Offset(left, c), align: Alignment.centerLeft));

    if (_subSize != null && item.subText != null && item.subText!.isNotEmpty) {
      (item.subTextStyle ?? _defaultSubStyle)
          .draw(canvas, mPaint, item.subText!, TextDrawConfig(Offset(width, c), align: Alignment.centerRight));
    }
  }
}
