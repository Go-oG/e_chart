import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'delaunay_helper.dart';

class DelaunayView extends SeriesView<DelaunaySeries, DelaunayHelper> {
  DelaunayView(super.series);

  @override
  DelaunayHelper buildLayoutHelper(DelaunayHelper? oldHelper) {
    return DelaunayHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    canvas.save();
    canvas.translate(translationX, translationY);
    each(layoutHelper.getShowNodeList(), (p0, p1) {
      p0.onDraw(canvas, mPaint);
      debugDraw(canvas, p0.attr.center(),color: Colors.black);
    });
    each(series.data, (p0, p1) {
      debugDraw(canvas, p0.toOffset(),color: Colors.white);
    });
    Path path=Path();
    each(layoutHelper.hull, (p, p1) {
      if(p1==0){
        path.moveTo(p.x.toDouble(),p.y.toDouble());
      }else{
        path.lineTo(p.x.toDouble(),p.y.toDouble());
      }
    });
    path.close();
    debugDrawPath(canvas, path);




    canvas.restore();
  }
  @override
  bool get enableDrag => true;
}
