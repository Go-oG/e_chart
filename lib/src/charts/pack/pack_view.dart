import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'layout/pack_helper.dart';


class PackView extends SeriesView<PackSeries, PackHelper> {
  double tx = 0;
  double ty = 0;
  double scale = 1;
  ChartTween? tween;

  ///临时记录最大层级
  late PackNode showNode;

  PackView(super.series);

  void _handleSelect(Offset offset) {
    PackNode? clickNode = findNode(offset);
    if (clickNode == null || clickNode == layoutHelper.rootNode) {
      return;
    }

    PackNode pn = clickNode.parent == null ? clickNode : clickNode.parent!;
    if (pn == showNode) {
      return;
    }
    series.onClick?.call(clickNode.data);
    showNode = pn;

    ///计算新的缩放系数
    double oldScale = scale;
    double newScale = min([width, height]) * 0.5 / pn.props.r;
    double scaleDiff = newScale - oldScale;

    ///计算偏移变化值
    double oldTx = tx;
    double oldTy = ty;
    double ntx = width / 2 - newScale * pn.props.x;
    double nty = height / 2 - newScale * pn.props.y;
    double diffTx = (ntx - oldTx);
    double diffTy = (nty - oldTy);

    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      scale = oldScale + scaleDiff;
      tx = oldTx + diffTx;
      ty = oldTy + diffTy;
      invalidate();
      return;
    }

    ChartDoubleTween tween = ChartDoubleTween(props: animation);
    tween.addListener(() {
      var t = tween.value;
      scale = oldScale + scaleDiff * t;
      tx = oldTx + diffTx * t;
      ty = oldTy + diffTy * t;
      invalidate();
    });
    tween.endListener = () {
      this.tween = null;
    };
    this.tween = tween;
    tween.start(context);
  }

  PackNode? findNode(Offset offset) {
    if (layoutHelper.rootNode == null) {
      return null;
    }
    List<PackNode> rl = [layoutHelper.rootNode!];
    PackNode? parent;
    while (rl.isNotEmpty) {
      PackNode node = rl.removeAt(0);
      Offset center = Offset(node.props.x, node.props.y);
      center = center.scale(scale, scale);
      center = center.translate(tx, ty);
      if (offset.inCircle(node.props.r * scale, center: center)) {
        parent = node;
        if (node.hasChild) {
          rl = [...node.children];
        } else {
          return node;
        }
      }
    }
    if (parent != null) {
      return parent;
    }
    return null;
  }

  //TODO 待完成
  void _handleCancelSelect() {}

  @override
  void onClick(Offset offset) {
    _handleSelect(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _handleSelect(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _handleSelect(offset);
  }

  @override
  void onHoverEnd() {
    _handleCancelSelect();
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    tx += diff.dx;
    ty += diff.dy;
    invalidate();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(selfBoxBound, globalBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    var root = layoutHelper.rootNode;
    if (root == null) {
      return;
    }
    canvas.save();
    Matrix4 matrix4 = Matrix4.compose(Vector3(tx, ty, 0), Quaternion.identity(), Vector3(scale, scale, 1));
    canvas.transform(matrix4.storage);
    root.each((node, p1, p2) {
      AreaStyle? style = series.areaStyleFun?.call(node);
      if (style != null) {
        Offset center = Offset(node.props.x, node.props.y);
        double r = node.props.r;
        style.drawCircle(canvas, mPaint, center, r);
      }
      return false;
    });
    canvas.restore();
    if (tween == null || !tween!.isAnimating) {
      ///这里分开绘制是为了优化当存在textScaleFactory时文字高度计算有问题
      root.each((node, p1, p2) {
        if (node.data.label != null && node.data.label!.isNotEmpty) {
          DynamicText label = node.data.label!;
          LabelStyle? labelStyle = series.labelStyleFun?.call(node);
          if (labelStyle == null || !labelStyle.show) {
            return false;
          }
          double r = node.props.r;
          Offset center = Offset(node.props.x, node.props.y);
          center = center.scale(scale, scale);
          center = center.translate(tx, ty);
          if (series.optTextDraw && r * 2 * scale < label.length * (labelStyle.textStyle.fontSize ?? 8) * 0.5) {
            return false;
          }
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
