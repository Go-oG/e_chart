import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';

class CCanvas {
  late final PaintingContext paintContext;
  Canvas? _canvas;

  CCanvas.fromPaintingContext(this.paintContext);

  CCanvas.fromCanvas(Canvas? canvas) {
    _canvas = canvas;
  }

  Canvas get canvas {
    if (_canvas != null) {
      return _canvas!;
    }
    return paintContext.canvas;
  }

  void clearCanvas() {
    _canvas = null;
  }

  void addLayer(Layer layer) {
    clearCanvas();
    paintContext.addLayer(layer);
  }

  void pushLayer(ContainerLayer childLayer, PaintingContextCallback painter, Offset offset, {Rect? childPaintBounds}) {
    clearCanvas();
    paintContext.pushLayer(childLayer, painter, offset, childPaintBounds: childPaintBounds);
  }

  void save() => canvas.save();

  void saveLayer(Rect? bounds, Paint paint) => canvas.saveLayer(bounds, paint);

  void restore() => canvas.restore();

  void restoreToCount(int count) => canvas.restoreToCount(count);

  int getSaveCount() => canvas.getSaveCount();

  void translate(double dx, double dy) => canvas.translate(dx, dy);

  void scale(double sx, [double? sy]) => canvas.scale(sx, sy);

  void rotate(double radians) => canvas.rotate(radians);

  void skew(double sx, double sy) => canvas.skew(sx, sy);

  void transform(Float64List matrix4) => canvas.transform(matrix4);

  Float64List getTransform() => canvas.getTransform();

  void clipRect(Rect rect, {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) =>
      canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);

  void clipRRect(RRect rrect, {bool doAntiAlias = true}) => canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);

  void clipPath(Path path, {bool doAntiAlias = true}) => canvas.clipPath(path, doAntiAlias: doAntiAlias);

  Rect getLocalClipBounds() => canvas.getLocalClipBounds();

  Rect getDestinationClipBounds() => canvas.getDestinationClipBounds();

  void drawColor(Color color, BlendMode blendMode) => canvas.drawColor(color, blendMode);

  void drawLine(Offset p1, Offset p2, Paint paint) => canvas.drawLine(p1, p2, paint);

  void drawPaint(Paint paint) => canvas.drawPaint(paint);

  void drawRect(Rect rect, Paint paint) => canvas.drawRect(rect, paint);

  void drawRRect(RRect rrect, Paint paint) => canvas.drawRRect(rrect, paint);

  void drawDRRect(RRect outer, RRect inner, Paint paint) => canvas.drawDRRect(outer, inner, paint);

  void drawOval(Rect rect, Paint paint) => canvas.drawOval(rect, paint);

  void drawCircle(Offset c, double radius, Paint paint) => canvas.drawCircle(c, radius, paint);

  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint) =>
      canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);

  void drawPath(Path path, Paint paint) => canvas.drawPath(path, paint);

  void drawImage(Image image, Offset offset, Paint paint) => canvas.drawImage(image, offset, paint);

  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) => canvas.drawImageRect(image, src, dst, paint);

  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) =>
      canvas.drawImageNine(image, center, dst, paint);

  void drawPicture(Picture picture) => canvas.drawPicture(picture);

  void drawParagraph(Paragraph paragraph, Offset offset) => canvas.drawParagraph(paragraph, offset);

  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) => canvas.drawPoints(pointMode, points, paint);

  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) =>
      canvas.drawRawPoints(pointMode, points, paint);

  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) =>
      canvas.drawVertices(vertices, blendMode, paint);

  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects, List<Color>? colors, BlendMode? blendMode,
          Rect? cullRect, Paint paint) =>
      canvas.drawAtlas(atlas, transforms, rects, colors, blendMode, cullRect, paint);

  void drawRawAtlas(Image atlas, Float32List rstTransforms, Float32List rects, Int32List? colors, BlendMode? blendMode,
          Rect? cullRect, Paint paint) =>
      canvas.drawRawAtlas(atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);

  void drawShadow(Path path, Color color, double elevation, bool transparentOccluder) =>
      canvas.drawShadow(path, color, elevation, transparentOccluder);
}
