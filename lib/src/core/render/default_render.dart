import 'dart:math';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:e_chart/src/coord/index.dart';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../component/index.dart';
import '../../model/index.dart';
import '../../utils/log_util.dart';
import 'chart_render.dart';
import 'ccanvas.dart';

class DefaultRender extends ChartRender {
  DefaultRender(super.option, super.tickerProvider, [super.devicePixelRatio]);

  @override
  void measure(double parentWidth, double parentHeight) {
    super.measure(parentWidth, parentHeight);
    double w = parentWidth;
    double h = parentHeight;
    if (context.title != null) {
      TitleView titleView = context.title!;
      titleView.measure(w, h);
      h -= titleView.height;
    }
    var legendView = context.legend;
    legendView.measure(w, h);
    h -= legendView.height;
    for (var v in context.coordList) {
      v.measure(parentWidth, parentHeight - legendView.height);
    }
    boxBound = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
  }

  @override
  void layout(double left, double top, double right, double bottom) {
    boxBound = Rect.fromLTRB(left, top, right, bottom);
    globalBound = getGlobalBounds();
    double width = right - left;
    double height = bottom - top;
    Rect rect = layoutTitleAndLegend(width, height);
    for (var v in context.coordList) {
      if (v is CircleCoordLayout) {
        double dx = v.props.center[0].convert(rect.width);
        double dy = v.props.center[1].convert(rect.height);
        double s = v.props.radius.last.convert(min<double>(rect.width, rect.height)) * 2;
        Rect r2 = Rect.fromCenter(center: Offset(dx, dy), width: s, height: s);
        v.layout(r2.left, r2.top, r2.right, r2.bottom);
        continue;
      }
      var margin = v.margin;
      double l = rect.left + margin.left;
      double t = rect.top + margin.top;
      v.layout(l, t, l + v.width, t + v.height);
    }
  }

  ///返回布局区域的坐标范围
  Rect layoutTitleAndLegend(double width, double height) {
    double titleTopUsed = 0;
    double titleBottomUsed = 0;

    if (context.title != null) {
      // TitleView titleView = context.title!;
      // ChartTitle title = titleView.title;
      //
      // Align2 position = title.position;
      // if (position == Align2.center) {
      //   position = Align2.start;
      // }
      //
      // int dx = -1;
      // int dy = position == Align2.start ? -1 : 1;
      // if (title.align == Align2.start) {
      //   dx = -1;
      // } else if (title.align == Align2.center) {
      //   dx = 0;
      // } else {
      //   dx = 1;
      // }
      //
      // double left = (width / 2 + dx * width / 2) + title.offset.dx;
      // double top = (height / 2 + dy * height / 2) + title.offset.dy;
      // if (position == Align2.end) {
      //   top = height - top;
      // }
      // titleView.layout(left, top, left + titleView.width, top + titleView.bottom);
      // if (position == Align2.start) {
      //   titleTopUsed = titleView.height + title.offset.dy;
      // } else {
      //   titleBottomUsed = titleView.height + title.offset.dy;
      // }
    }

    var legendView = context.legend;
    Legend legend = legendView.legend;
    Align2 vAlign = legend.vAlign;
    Align2 hAlign = legend.hAlign;
    if (vAlign == Align2.center && hAlign == Align2.center) {
      vAlign = Align2.start;
    }
    double top;
    double left;
    if (vAlign == Align2.start) {
      top = titleTopUsed + legend.offset.dy;
    } else if (vAlign == Align2.center) {
      top = height / 2 - legendView.height / 2;
    } else {
      top = height - titleBottomUsed - legendView.height;
    }
    if (hAlign == Align2.start) {
      left = legend.offset.dx;
    } else if (hAlign == Align2.center) {
      left = legend.offset.dx + ((width - legendView.width) / 2);
    } else {
      left = width - legendView.width + legend.offset.dx;
    }
    legendView.layout(left, top, left + legendView.width, top + legendView.height);

    double l = 0;
    double t = 0;
    double r = width;
    double b = height;
    if (context.title != null) {
      TitleView titleView = context.title!;
      t = max(t, titleView.bottom);
      b = min(b, titleView.top);
    }

    if (hAlign == Align2.start) {
      l = max(l, legendView.right);
    } else if (hAlign == Align2.end) {
      r = min(r, legendView.left);
    }
    if (vAlign == Align2.start) {
      t = max(t, legendView.bottom);
    } else if (vAlign == Align2.end) {
      b = min(b, legendView.top);
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  final Paint _paint = Paint();

  @override
  void onDraw(CCanvas canvas) {
    var bc = context.option.theme.backgroundColor;
    if (bc != null) {
      _paint.color = bc;
      _paint.style = PaintingStyle.fill;
      canvas.drawRect(selfBoxBound, mPaint);
    }

    for (var v in context.coordList) {
      try {
        canvas.save();
        canvas.translate(v.left, v.top);
        v.draw(canvas);
        canvas.restore();
      } catch (e, trace) {
        Logger.e2(e, trace: trace);
        rethrow;
      }
    }
    try {
      var legend = context.legend;
      canvas.save();
      canvas.translate(legend.left, legend.top);
      legend.draw(canvas);
      canvas.restore();
    } catch (e, trace) {
      Logger.e2(e, trace: trace);
      rethrow;
    }
  }

  @override
  void dispose() {
    _paint.reset();
    super.dispose();
  }
}
