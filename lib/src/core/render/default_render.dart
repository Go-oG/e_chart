import 'dart:math';
import 'package:e_chart/src/coord/index.dart';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    for (var v in context.coordList) {
      v.measure(w, h);
    }
    boxBound = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
  }

  @override
  void layout(double left, double top, double right, double bottom) {
    boxBound = Rect.fromLTRB(left, top, right, bottom);
    globalBound = getGlobalBounds();
    double width = right - left;
    double height = bottom - top;
    Rect rect = Rect.fromLTWH(0, 0, width, height);
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
  }

  @override
  void dispose() {
    _paint.reset();
    super.dispose();
  }
}
