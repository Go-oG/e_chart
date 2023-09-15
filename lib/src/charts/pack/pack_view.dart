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
    var root = layoutHelper.rootNode;
    if (root == null) {
      return;
    }
    var tx = layoutHelper.tx;
    var ty = layoutHelper.ty;
    var scale = layoutHelper.scale;

    canvas.save();
    Matrix4 matrix4 = Matrix4.compose(Vector3(tx, ty, 0), Quaternion.identity(), Vector3(scale, scale, 1));
    canvas.transform(matrix4.storage);
    root.each((node, p1, p2) {
      if (layoutHelper.needDraw(node)) {
        node.onDraw(canvas, mPaint);
      }
      return false;
    });
    canvas.restore();

    ///这里分开绘制是为了优化当存在textScaleFactory时文字高度计算有问题
    root.each((node, p1, p2) {
      if (!layoutHelper.needDraw(node)) {
        return false;
      }
      var label = node.data.label;
      if (label != null && label.isNotEmpty) {
        var labelStyle = series.getLabelStyle(context, node);
        if (labelStyle == null || !labelStyle.show) {
          return false;
        }
        double r = node.r;
        if (series.optTextDraw && r * 2 * scale < label.length * (labelStyle.textStyle.fontSize ?? 8) * 0.5) {
          return false;
        }
        Offset center = node.center;
        center = center.scale(scale, scale);
        center = center.translate(tx, ty);
        TextDrawInfo config = TextDrawInfo(
          center,
          align: Alignment.center,
          maxWidth: r * 2 * scale * 0.98,
          maxLines: 1,
        );
        labelStyle.draw(canvas, mPaint, label, config);
      }
      return false;
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
}
