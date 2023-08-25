import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'layout/pack_helper.dart';

class PackView extends SeriesView<PackSeries, PackHelper> {
  PackView(super.series);

  @override
  bool get enableDrag => true;

  @override
  void onDraw(Canvas canvas) {
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
      AreaStyle? style = series.getItemStyle(context, node);
      var borderStyle = series.getBorderStyle(context, node);
      if (style == null && borderStyle == null) {
        return false;
      }
      Offset center = Offset(node.props.x, node.props.y);
      double r = node.props.r;
      style?.drawCircle(canvas, mPaint, center, r);
      borderStyle?.drawArc(canvas, mPaint, r - borderStyle.width / 2, 0, 360);
      return false;
    });
    canvas.restore();

    ///这里分开绘制是为了优化当存在textScaleFactory时文字高度计算有问题
    root.each((node, p1, p2) {
      var label = node.data.label;
      if (label != null && label.isNotEmpty) {
        LabelStyle? labelStyle = series.getLabelStyle(context, node);
        if (labelStyle == null || !labelStyle.show) {
          return false;
        }
        double r = node.props.r;

        if (series.optTextDraw && r * 2 * scale < label.length * (labelStyle.textStyle.fontSize ?? 8) * 0.5) {
          return false;
        }

        Offset center = Offset(node.props.x, node.props.y);
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
  PackHelper buildLayoutHelper() {
    return PackHelper(context, series);
  }
}
