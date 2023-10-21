import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'sankey_helper.dart';

/// 桑基图
class SankeyView extends SeriesView<SankeySeries, SankeyHelper> {
  SankeyView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var ap = layoutHelper.animationProcess;
    canvas.save();
    canvas.translate(translationX, translationY);
    Rect clipRect;
    if (series.direction == Direction.horizontal) {
      clipRect = Rect.fromLTWH(0, 0, width * ap, height);
    } else {
      clipRect = Rect.fromLTWH(0, 0, width, height * ap);
    }
    canvas.clipRect(clipRect);
    _drawLink(canvas, clipRect);
    for (var node in layoutHelper.nodes) {
      if (!node.attr.rect.overlaps(clipRect)) {
        continue;
      }
      node.onDraw(canvas, mPaint);
    }
    canvas.restore();
  }

  void _drawLink(CCanvas canvas, Rect clipRect) {
    for (var link in layoutHelper.links) {
      link.onDraw(canvas, mPaint);
    }
  }

  @override
  SankeyHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    return SankeyHelper(context, this, series);
  }

  @override
  bool get enableDrag => true;
}
