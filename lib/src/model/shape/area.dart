import 'package:flutter/material.dart';

import '../constans.dart';
import 'chart_shape.dart';

///代表一个封闭的图形
///其路径由给定的点组成
class Area implements Shape {
  final List<Offset> upList;
  final List<Offset> downList;

  final bool upSmooth;
  final bool downSmooth;

  Area(this.upList, this.downList, {this.upSmooth = true, this.downSmooth = true}) {
    if (upList.isEmpty || downList.isEmpty) {
      throw FlutterError('Point List must not empty');
    }
  }

  Path? _path;

  @override
  Path toPath(bool close) {
    if (_path != null) {
      return _path!;
    }
    _path = buildPath();
    return _path!;
  }

  Path buildPath() {
    Path mPath = Path();
    if (upSmooth) {
      Offset firstPoint = upList.first;
      mPath.moveTo(firstPoint.dx, firstPoint.dy);
      List<Offset> tmpList = [];
      tmpList.add(upList[0]);
      tmpList.addAll(upList);
      tmpList.add(upList.last);
      tmpList.add(upList.last);
      for (int i = 1; i < tmpList.length - 3; i++) {
        List<Offset> list = _getCtrlPoint(tmpList, i);
        Offset leftPoint = list[0];
        Offset rightPoint = list[1];
        Offset p = tmpList[i + 1];
        mPath.cubicTo(leftPoint.dx, leftPoint.dy, rightPoint.dx, rightPoint.dy, p.dx, p.dy);
      }
    } else {
      bool first = true;
      for (var of in upList) {
        if (first) {
          first = false;
          mPath.moveTo(of.dx, of.dy);
        } else {
          mPath.lineTo(of.dx, of.dy);
        }
      }
    }
    Offset end = downList.last;
    mPath.lineTo(end.dx, end.dy);
    if (downSmooth) {
      List<Offset> tmpList = [];
      tmpList.add(downList.first);
      tmpList.addAll(downList);
      tmpList.add(downList.last);
      tmpList.add(downList.last);
      for (int i = tmpList.length - 3; i >= 2; i--) {
        List<Offset> list = _getCtrlPoint(tmpList, i, reverse: true);
        Offset leftPoint = list[0];
        Offset rightPoint = list[1];
        Offset p = tmpList[i - 1];
        mPath.cubicTo(leftPoint.dx, leftPoint.dy, rightPoint.dx, rightPoint.dy, p.dx, p.dy);
      }
    } else {
      for (var c in downList.reversed) {
        mPath.lineTo(c.dx, c.dy);
      }
    }
    mPath.close();
    return mPath;
  }

  ///TODO 后续优化
  List<Offset> _getCtrlPoint(
    List<Offset> pointList,
    int curIndex, {
    bool reverse = false,
  }) {
    double ratio = Constants.smoothRatio;
    Offset cur = pointList[curIndex];
    int li = reverse ? curIndex + 1 : curIndex - 1;
    int ri = reverse ? curIndex - 1 : curIndex + 1;
    int ri2 = reverse ? curIndex - 2 : curIndex + 2;
    Offset left = pointList[li];
    Offset right = pointList[ri];
    Offset right2 = pointList[ri2];

    double ax = cur.dx + (right.dx - left.dx) * ratio;
    double ay = cur.dy + (right.dy - left.dy) * ratio;
    double bx = right.dx - (right2.dx - cur.dx) * ratio;
    double by = right.dy - (right2.dy - cur.dy) * ratio;

    return [Offset(ax, ay), Offset(bx, by)];
  }

  @override
  bool internal(Offset offset) {
    return toPath(true).contains(offset);
  }
}
