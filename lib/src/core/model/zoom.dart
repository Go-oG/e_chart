import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';

import '../../model/chart_error.dart';
import '../render/ccanvas.dart';

///处理视图平移和缩放相关的工具类
class Zoom {
  ///视图宽高
  double width;
  double height;

  ///当前的平移量 区分正负
  double translationX;
  double translationY;

  ///X轴平移范围
  double minTranslationX;
  double maxTranslationX;

  ///Y 轴平移范围
  double minTranslationY;
  double maxTranslationY;

  ///缩放量
  double scaleValue;

  ///最大缩放量(正整数 包含0)
  double maxScale;

  ///最下缩放量(正整数 包含0)
  double minScale;

  Zoom(
    this.width,
    this.height, {
    this.translationX = 0,
    this.translationY = 0,
    this.minTranslationX = double.minPositive,
    this.maxTranslationX = double.maxFinite,
    this.minTranslationY = double.minPositive,
    this.maxTranslationY = double.maxFinite,
    this.scaleValue = 1,
    this.minScale = 0.5,
    this.maxScale = 100,
  });

  void reset({
    double? width,
    double? height,
    double? translationX,
    double? translationY,
    double? minTranslationX,
    double? maxTranslationX,
    double? minTranslationY,
    double? maxTranslationY,
    double? scale,
    double? minScale,
    double? maxScale,
    bool allowAdjust = true,
  }) {
    if (width != null) {
      this.width = width;
    }
    if (height != null) {
      this.height = height;
    }
    if (translationX != null) {
      this.translationX = translationX;
    }
    if (translationY != null) {
      this.translationY = translationY;
    }
    if (minTranslationX != null) {
      this.minTranslationX = minTranslationX;
    }
    if (maxTranslationX != null) {
      this.maxTranslationX = maxTranslationX;
    }
    if (minTranslationY != null) {
      this.minTranslationY = minTranslationY;
    }
    if (maxTranslationY != null) {
      this.maxTranslationY = maxTranslationY;
    }

    if (scale != null) {
      scaleValue = scale;
    }
    if (minScale != null) {
      this.minScale = minScale;
    }

    ///修正数据
    if (this.maxTranslationY < this.minTranslationY) {
      throw ChartError("maxTranslationY must > minTranslationY");
    }
    if (this.maxTranslationX < this.minTranslationX) {
      throw ChartError("maxTranslationX must > minTranslationX");
    }

    if (this.translationX > this.maxTranslationX) {
      if (!allowAdjust) {
        throw ChartError("translationX > maxTranslation");
      }
      this.translationX = this.maxTranslationX;
    }
    if (this.translationX < this.minTranslationX) {
      if (!allowAdjust) {
        throw ChartError("translationX < minTranslationX");
      }
      this.translationX = this.minTranslationX;
    }

    if (this.translationY > this.maxTranslationY) {
      if (!allowAdjust) {
        throw ChartError("translationY > maxTranslationY");
      }
      this.translationY = this.maxTranslationY;
    }
    if (this.translationY < this.minTranslationY) {
      if (!allowAdjust) {
        throw ChartError("translationY < minTranslationY");
      }
      this.translationY = this.minTranslationY;
    }

    if (scaleValue > this.maxScale) {
      if (!allowAdjust) {
        throw ChartError("scale > maxScale");
      }
      scaleValue = this.maxScale;
    }

    if (scaleValue < this.minScale) {
      if (!allowAdjust) {
        throw ChartError("scale < minScale");
      }
      scaleValue = this.minScale;
    }
  }

  void recover() {
    translationX = translationY = 0;
    scaleValue = 1;
  }

  ///更改平移
  void translation(double dx, double dy) {
    translationX += dx;
    translationX = max(translationX, minTranslationX);
    translationX = min(translationX, maxTranslationX);

    translationY += dy;
    translationY = max(translationY, minTranslationY);
    translationY = min(translationY, maxTranslationY);
  }

  ///执行缩放操作
  ///如果center不为空 则以给定点为缩放中心 否则则为中心点为缩放中心
  void scale(double dv, [Offset? center]) {
    center ??= Offset.zero;
    var old = center;
    center = center.translate(-translationX, -translationY);
    center *= scaleValue;
    scaleValue += dv;
    scaleValue = max(scaleValue, minScale);
    scaleValue = min(scaleValue, maxScale);
    Matrix4 matrix4 = Matrix4.identity();
    matrix4.setTranslationRaw(translationX, translationY, 0);
    matrix4.translate(center.dx, center.dy);
    matrix4.scale(scaleValue);
    matrix4.translate(-center.dx, -center.dy);
    var tr=matrix4.getTranslation();
    translationX=tr.x;
    translationY=tr.y;
    scaleValue=matrix4.getMaxScaleOnAxis();


  }

  void mapCanvas(CCanvas canvas, VoidCallback drawCall) {
    canvas.save();
    canvas.translate(translationX, translationY);
    canvas.scale(scaleValue);
    drawCall.call();
    canvas.restore();
  }
}
