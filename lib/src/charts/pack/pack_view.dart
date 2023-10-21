import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'pack_helper.dart';

class PackView extends SeriesView<PackSeries, PackHelper> {
  PackView(super.series);

  @override
  bool get enableDrag => true;

  @override
  void onDraw(CCanvas canvas) {
    Matrix4 matrix4 = Matrix4.compose(
      Vector3(translationX, translationY, 0),
      Quaternion.identity(),
      Vector3(scaleX, scaleX, 1),
    );
    canvas.save();
    canvas.transform(matrix4.storage);
    var nodeList = layoutHelper.nodeList;
    each(nodeList, (node, p1) {
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();

    ///这里分开绘制是为了优化当存在textScaleFactory时文字高度计算有问题
    each(nodeList, (node, p2) {
      var label = node.label;
      if (label.notDraw) {
        return;
      }
      double r = node.r;
      if (series.optTextDraw && r * 2 * scaleX < label.text.length * (label.style.textStyle.fontSize ?? 8) * 0.5) {
        return;
      }
      canvas.save();
      var dx = translationX + label.offset.dx * (scaleX - 1);
      var dy = translationY + label.offset.dy * (scaleX - 1);
      canvas.translate(dx, dy);
      label.draw(canvas, mPaint);
      canvas.restore();
    });
  }

  void drawBackground(Canvas canvas) {
    if (series.backgroundColor != null) {
      mPaint.reset();
      mPaint.color = series.backgroundColor!;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), mPaint);
    }
  }

  @override
  PackHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    return PackHelper(context, this, series);
  }

  @override
  bool get enableHover => false;
}
