import 'package:flutter/material.dart';
import '../../core/view.dart';
import '../../ext/int_ext.dart';
import 'bar_series.dart';
import 'layout_helper.dart';
import 'touch_helper.dart';

///用于处理Bar、line、point、 视图绘制相关不会包含坐标轴相关的计算和绘制
class BarView extends  ChartView {
  final BarSeries series;
  final ValueNotifier<IntWrap> notifier = ValueNotifier(0.wrap());
  late LayoutHelper _layout;
  late TouchHelper touchHelper;

  ///用户优化视图绘制
  BarView(this.series) {
    notifier.addListener(() {
      invalidate();
    });
  }

  @override
  void onAttach() {
    super.onAttach();
    _layout = LayoutHelper(series,  notifier);
    touchHelper = TouchHelper(notifier, _layout);
    touchHelper.clear();
  }

  @override
  void onDetach() {
    super.onDetach();
    touchHelper.clear();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.layout(0, 0, width, height);
  }

  @override
  void onDraw(Canvas canvas) {
    drawHoverBk(canvas);
    drawBarElement(canvas);
    drawLineElement(canvas);
    drawOtherElement(canvas);
    drawMakePoint(canvas);
    drawMakeLine(canvas);
  }

  /// 绘制最后面的Hover移动区域
  void drawHoverBk(Canvas canvas) {
    // if (series.actionStyleFun == null) {
    //   return;
    // }
    // Rect? hoverRect = touchHelper.hoverRect;
    // if (hoverRect == null) {
    //   return;
    // }
    // AreaStyle? style = series.actionStyleFun!.call(const UserAction(maskFlag: 0));
    // style?.drawRect(canvas, paint, hoverRect);
  }

  /// 绘制柱状图
  void drawBarElement(Canvas canvas) {
    for (var element in _layout.nodeList) {
      for (var node in element.nodeList) {
        for (var node2 in node.nodeList) {
          node2.draw(canvas, mPaint);
        }
      }
    }
  }

  /// 绘制折线图
  void drawLineElement(Canvas canvas) {
    // double animatorPercent = 1;
    // List<GroupNode> elementList = _layout.lineGroupElementList;
    // if (elementList.isEmpty) {
    //   return;
    // }
    // canvas.save();
    // for (var element in elementList) {
    //   element.draw(canvas, paint, touchHelper);
    // }
    // canvas.restore();
  }

  /// 绘制其它图形
  void drawOtherElement(Canvas canvas) {
    // List<GroupNode> elementList = _layout.otherGroupElementList;
    // if (elementList.isEmpty) {
    //   return;
    // }
  }

  /// 绘制标记点
  void drawMakePoint(Canvas canvas) {
    // if (series.markPointFun == null) {
    //   return;
    // }
    //
    // for (var element in series.data) {
    //   MarkPoint? makePoint = series.markPointFun!.call(element);
    //   if (makePoint == null) {
    //     continue;
    //   }
    //   GlobalValue valueInfo = _layout.getBarGroupValueInfo(element);
    //   SingleData? barData = valueInfo.getBarData(makePoint.markType);
    //   if (barData == null) {
    //     continue;
    //   }
    //   SingleNode? singleElement = _layout.findSingleElement(barData);
    //   if (singleElement == null || singleElement.data == null) {
    //     continue;
    //   }
    //   String text = formatNumber(singleElement.data.y, makePoint.precision);
    //   makePoint.draw(canvas, paint, singleElement.positionRect.topCenter, text);
    // }
  }

  /// 绘制标记线
  void drawMakeLine(Canvas canvas) {
    // if (series.markLineFun == null) {
    //   return;
    // }
    //
    // for (var element in series.data) {
    //   MarkLine? markLine = series.markLineFun!.call(element);
    //   if (markLine == null) {
    //     continue;
    //   }
    //   GlobalValue valueInfo = _layout.getBarGroupValueInfo(element);
    //   Offset? startOffset, endOffset;
    //   String? endText;
    //   if (markLine.endMarkType != null) {
    //     SingleData? startBarData = valueInfo.getBarData(markLine.startMarkType);
    //     SingleData? endBarData = valueInfo.getBarData(markLine.endMarkType!);
    //     if (startBarData == null || endBarData == null) {
    //       continue;
    //     }
    //     SingleNode? startElement = _layout.findSingleElement(startBarData);
    //     SingleNode? endElement = _layout.findSingleElement(endBarData);
    //     if (startElement == null || endElement == null) {
    //       print('SingleElement为空');
    //       continue;
    //     }
    //     startOffset = startElement.positionRect.topCenter;
    //     endOffset = endElement.positionRect.topCenter;
    //   } else {
    //     double? value = valueInfo.getValue(markLine.startMarkType);
    //     if (value == null) {
    //       continue;
    //     }
    //     double maxValue = _layout.getAxisMaxValue(element);
    //     double minValue = _layout.getAxisMinValue(element);
    //     double startPercent = (value - minValue) / (maxValue - minValue);
    //     startOffset = Offset(0, (1 - startPercent) * _layout.height);
    //     endOffset = Offset(width, startOffset.dy);
    //     endText = formatNumber(value, markLine.precision);
    //   }
    //   markLine.draw(canvas, paint, startOffset, endOffset, null, endText);
    // }
  }
}
