import 'dart:math';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:e_chart/src/coord/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../component/index.dart';
import '../../model/index.dart';
import 'base_render.dart';
import '../view.dart';

class DefaultRender extends BaseRender {
  DefaultRender(super.config, super.tickerProvider, [super.devicePixelRatio]);

  @override
  void onMeasure(double parentWidth, double parentHeight) {
    double w = parentWidth;
    double h = parentHeight;
    if (context.title != null) {
      TitleView titleView = context.title!;
      titleView.measure(w, h);
      h -= titleView.height;
    }
    if (context.legend != null) {
      LegendViewGroup legendView = context.legend!;
      legendView.measure(w, h);
      h -= legendView.height;
    }
    List<ChartView> renderList = context.coordList;
    for (var v in renderList) {
      v.measure(parentWidth, parentHeight);
    }
  }

  @override
  void onLayout(double width, double height) {
    Rect rect = layoutTitleAndLegend(width, height);
    for (var v in context.coordList) {
      if (v is CircleCoord) {
        double dx = v.props.center[0].convert(rect.width);
        double dy = v.props.center[1].convert(rect.height);
        double r = v.props.radius.convert(min(rect.width, rect.height));
        Rect r2 = Rect.fromCenter(center: Offset(dx, dy), width: r * 2, height: r * 2);
        v.layout(r2.left, r2.top, r2.right, r2.bottom);
      } else {
        var props = v.props;
        double lm = props.margin.left;
        double tm = props.margin.top;
        v.layout(rect.left + lm, rect.top + tm, rect.left + lm + v.width, rect.top + tm + v.height);
      }
    }
  }

  ///返回布局区域的坐标范围
  Rect layoutTitleAndLegend(double width, double height) {
    double titleTopUsed = 0;
    double titleBottomUsed = 0;

    if (context.title != null) {
      TitleView titleView = context.title!;
      ChartTitle title = titleView.title;

      Align2 position = title.position;
      if (position == Align2.center) {
        position = Align2.start;
      }

      int dx = -1;
      int dy = position == Align2.start ? -1 : 1;
      if (title.align == Align2.start) {
        dx = -1;
      } else if (title.align == Align2.center) {
        dx = 0;
      } else {
        dx = 1;
      }

      double left = (width / 2 + dx * width / 2) + title.offset.dx;
      double top = (height / 2 + dy * height / 2) + title.offset.dy;
      if (position == Align2.end) {
        top = height - top;
      }
      titleView.layout(left, top, left + titleView.width, top + titleView.bottom);
      if (position == Align2.start) {
        titleTopUsed = titleView.height + title.offset.dy;
      } else {
        titleBottomUsed = titleView.height + title.offset.dy;
      }
    }

    if (context.legend != null) {
      LegendViewGroup legendView = context.legend!;
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
        left = legend.offset.dx + (width / 2 - legendView.width / 2);
      } else {
        left = width - legend.offset.dx - legendView.width;
      }
      legendView.layout(left, top, left + legendView.width, top + legendView.height);
    }

    double l = 0;
    double t = 0;
    double r = width;
    double b = height;
    if (context.title != null) {
      TitleView titleView = context.title!;
      t = max(t, titleView.bottom);
      b = min(b, titleView.top);
    }
    if (context.legend != null) {
      LegendViewGroup legend = context.legend!;
      Align2 hAlign = legend.legend.hAlign;
      Align2 vAlign = legend.legend.vAlign;
      if (hAlign == Align2.start) {
        l = max(l, legend.right);
      } else if (hAlign == Align2.end) {
        r = min(r, legend.left);
      }
      if (vAlign == Align2.start) {
        t = max(t, legend.bottom);
      } else if (vAlign == Align2.end) {
        b = min(b, legend.top);
      }
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  @override
  void onDraw(Canvas canvas) {
    Paint mPaint = Paint();
    mPaint.color = context.config.theme.backgroundColor;
    mPaint.style = PaintingStyle.fill;
    canvas.drawRect(getGlobalAreaBounds(), mPaint);

    for (var v in context.coordList) {
      canvas.save();
      canvas.translate(v.left, v.top);
      v.draw(canvas);
      canvas.restore();
    }
    renderToolTip(canvas);
  }

  void renderToolTip(Canvas canvas) {
    if (context.toolTip == null) {
      return;
    }
    ToolTipView tipView = context.toolTip!;
    Offset p = tipView.builder.onMenuPosition();
    tipView.measure(size.width, size.height);
    tipView.layout(p.dx, p.dy, p.dx + tipView.width, p.dy + tipView.height);
    tipView.draw(canvas);
  }
}
