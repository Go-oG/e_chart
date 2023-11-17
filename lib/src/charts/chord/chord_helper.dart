import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ChordHelper extends LayoutHelper3<ChordData, ChordLink, ChordSeries> {
  ChordHelper(super.context, super.view, super.series);

  double radius = 0;
  double radiusWidth = 0;
  double chordGap = 0;
  double chordRadius = 0;
  Offset center = Offset.zero;

  @override
  void onLayout(LayoutType type) {
    const num allAngle = 360;
    List<ChordLink> links = List.from(series.data);
    var helper = series.dataHelper();
    List<ChordData> dataList = helper.dataList;

    each(dataList, (p0, p1) {
      p0.dataIndex = p1;
      p0.styleIndex = p1;
      p0.updateStyle(context, series);
    });
    each(links, (p0, p1) {
      p0.dataIndex = p1;
      p0.styleIndex = p1;
      p0.updateStyle(context, series);
    });

    int n = dataList.length;
    num allPadAngle = 0;
    if (n > 1) {
      allPadAngle = series.padAngle * n;
    }
    num remainAngle = allAngle - allPadAngle;
    num k = remainAngle / sumBy<ChordData>(dataList, (p0) => p0.value);
    num minRadius = min([width, height]) / 2;
    radius = series.radius.convert(minRadius);
    radiusWidth = series.chordWidth.convert(minRadius);
    chordGap = series.chordGap.convert(minRadius);
    chordRadius = radius - radiusWidth - chordGap;
    center = computeCenter();

    Map<ChordData, num> offsetMap = {};
    num startAngle = series.startAngle;
    each(dataList, (data, p1) {
      num sw = k * data.value;
      data.attr = Arc(
        center: center,
        startAngle: startAngle,
        sweepAngle: sw,
        innerRadius: radius - radiusWidth,
        outRadius: radius,
        cornerRadius: 0,
        padAngle: series.padAngle,
        maxRadius: radius,
      );
      startAngle += sw + series.padAngle;
      offsetMap[data] = data.attr.startAngle;
    });

    ///计算每个link的位置
    each(links, (p0, p1) {
      var source = p0.source;
      var so = offsetMap[source]!;
      var sw = k * p0.value;
      p0.sourceStartAngle = so;
      p0.sourceEndAngle = so + sw;
      offsetMap[source] = so + sw;

      var target = p0.target;
      so = offsetMap[target]!;
      p0.targetStartAngle = so;
      p0.targetEndAngle = so + sw;
      offsetMap[target] = so + sw;
    });

    ///构建linkPath
    each(links, (p0, p1) {
      p0.attr = _buildLinkPath(p0);
    });

    dataSet = dataList;
    linkSet = links;
  }

  Path _buildLinkPath(ChordLink link) {
    Offset center = link.target.attr.center;
    double sourceRadius = link.source.attr.innerRadius.toDouble(),
        sourceStartAngle = link.sourceStartAngle * StaticConfig.angleUnit,
        sourceEndAngle = link.sourceEndAngle * StaticConfig.angleUnit,
        targetRadius = link.target.attr.innerRadius.toDouble(),
        targetStartAngle = link.targetStartAngle * StaticConfig.angleUnit,
        targetEndAngle = link.targetEndAngle * StaticConfig.angleUnit;

    Path path = Path();
    Offset sourceStart = circlePointRadian(sourceRadius, sourceStartAngle, center);
    path.moveTo2(sourceStart);
    Rect rect = Rect.fromCircle(center: center, radius: sourceRadius);
    path.arcTo(rect, sourceStartAngle, sourceEndAngle - sourceStartAngle, false);

    Offset c2 = circlePointRadian(targetRadius, targetStartAngle, center);
    path.quadraticBezierTo(center.dx, center.dy, c2.dx, c2.dy);
    rect = Rect.fromCircle(center: center, radius: targetRadius);
    path.arcTo(rect, targetStartAngle, targetEndAngle - targetStartAngle, false);
    path.quadraticBezierTo(center.dx, center.dy, sourceStart.dx, sourceStart.dy);
    return path;
  }

  Offset computeCenter() {
    var x = series.center.first.convert(width);
    var y = series.center.last.convert(height);
    return Offset(x, y);
  }

  @override
  List<ChordLink> getDataInLink(ChordData data) {
    return series.dataHelper().innerMap[data] ?? [];
  }

  @override
  List<ChordLink> getDataOutLink(ChordData data) {
    return series.dataHelper().outMap[data] ?? [];
  }

  @override
  ChordData getLinkSource(ChordLink link) => link.source;

  @override
  ChordData getLinkTarget(ChordLink link) => link.target;

}
