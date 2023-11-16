import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';


class ThemeRiverHelper extends LayoutHelper2<ThemeRiverData, ThemeRiverSeries> {
  num maxTransX = 0, maxTransY = 0;
  double animatorPercent = 1;

  ThemeRiverHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    resetTranslation();
    List<ThemeRiverData> newList = [...series.data];
    each(newList, (d, i) {
      d.dataIndex = i;
      d.groupIndex = 0;
      d.updateStyle(context, series);
    });
    layoutNode(newList);

    var animation = getAnimation(type, newList.length);
    if (animation == null) {
      dataSet = newList;
      animatorPercent = 1;
      return;
    }
    var tween = ChartDoubleTween(option: animation);
    tween.addStartListener(() {
      inAnimation = true;
      dataSet = newList;
    });
    tween.addListener(() {
      animatorPercent = tween.value;
      notifyLayoutUpdate();
    });
    tween.addEndListener(() {
      inAnimation = false;
    });
    context.addAnimationToQueue([AnimationNode(tween, animation, type)]);
  }

  void layoutNode(List<ThemeRiverData> newList) {
    final List<List<_InnerNode>> innerNodeList = [];
    for (var ele in newList) {
      List<_InnerNode> tmp = [];
      for (var e2 in ele.value) {
        tmp.add(_InnerNode(e2));
      }
      if (tmp.isNotEmpty) {
        innerNodeList.add(tmp);
      }
    }
    var base = _computeBaseline(innerNodeList);
    List<double> baseLine = base['y0'];
    Direction direction = series.direction;

    double tw = (direction == Direction.horizontal ? height : width) * 0.95;
    double ky = tw / base['max'];

    int n = innerNodeList.length;
    int m = innerNodeList[0].length;
    tw = direction == Direction.horizontal ? width : height;
    double iw = m <= 1 ? 0 : tw / (m - 1);
    if (m > 1 && series.minInterval != null) {
      double minw = series.minInterval!.convert(tw);
      if (iw < minw) {
        iw = minw;
      }
    }
    double baseY0;
    for (int j = 0; j < m; ++j) {
      baseY0 = baseLine[j] * ky;
      innerNodeList[0][j].setItemLayout(0, iw * j, baseY0, innerNodeList[0][j].value * ky);
      for (int i = 1; i < n; ++i) {
        baseY0 += innerNodeList[i - 1][j].value * ky;
        innerNodeList[i][j].setItemLayout(i, iw * j, baseY0, innerNodeList[i][j].value * ky);
      }
    }

    for (int j = 0; j < innerNodeList.length; j++) {
      ThemeRiverData node = newList[j];
      var ele = innerNodeList[j];
      List<Offset> pList = [];
      List<Offset> pList2 = [];
      for (int i = 0; i < ele.length; i++) {
        if (direction == Direction.horizontal) {
          pList.add(Offset(ele[i].x, ele[i].py0));
          pList2.add(Offset(ele[i].x, ele[i].py + ele[i].py0));
        } else {
          pList.add(Offset(ele[i].py0, ele[i].x));
          pList2.add(Offset(ele[i].py + ele[i].py0, ele[i].x));
        }
      }
      node.update(pList, pList2, series.smooth, series.direction);
    }
  }

  Map<String, dynamic> _computeBaseline(List<List<_InnerNode>> data) {
    int layerNum = data.length;
    int pointNum = data[0].length;
    List<double> sums = [];
    double max = 0;

    ///按照时间序列 计算并保存每个序列值和，且和全局最大序列值和进行比较保留最大的
    for (int i = 0; i < pointNum; ++i) {
      double temp = 0;
      for (int j = 0; j < layerNum; ++j) {
        temp += data[j][i].value;
      }
      if (temp > max) {
        max = temp;
      }
      sums.add(temp);
    }

    ///计算每个序列与最大序列值差值的一半
    List<double> y0 = List.filled(pointNum, 0);
    for (int k = 0; k < pointNum; ++k) {
      y0[k] = (max - sums[k]) / 2;
    }

    max = 0;
    for (int l = 0; l < pointNum; ++l) {
      double sum = sums[l] + y0[l];
      if (sum > max) {
        max = sum;
      }
    }
    return {'y0': y0, 'max': max};
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    for (var diff in list) {
      diff.data.attr.index = diff.old ? 0 : 100;
    }
    dataSet.sort((a, b) {
      return a.attr.index.compareTo(b.attr.index);
    });
    super.onRunUpdateAnimation(list, animation);
  }
}

class _InnerNode {
  final num value;
  int index = 0;
  double x = 0;
  double py = 0;
  double py0 = 0;

  _InnerNode(this.value);

  void setItemLayout(int index, double px, double py0, double py) {
    this.index = index;
    x = px;
    this.py = py;
    this.py0 = py0;
  }
}
