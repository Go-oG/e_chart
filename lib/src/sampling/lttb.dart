import 'package:e_chart/e_chart.dart';

/// LTTB 采样算法
class LTTBAlgorithms<T> {
  final Fun2<T, num> valueFun;
  final Fun2<T, num> indexFun;
  final int threshold;

  LTTBAlgorithms(this.indexFun, this.valueFun, this.threshold);

  List<T> downSampling(List<T> sortList) {
    if (sortList.length <= threshold || sortList.length <= 2) {
      return sortList;
    }

    int bucketCount = ((sortList.length - 2) / threshold).ceil() + 2;
    int bucketSize = ((sortList.length - 2) / (bucketCount - 2)).ceil();

    List<List<T>> sl = splitList(sortList.getRange(1, sortList.length - 1), bucketSize);

    List<List<T>> bucketList = List.generate(bucketCount, (index) {
      if (index == 0) {
        return [sortList[0]];
      } else if (index == bucketCount - 1) {
        return [sortList.last];
      } else {
        return sl[index - 1];
      }
    });

    List<num> preBucket = [indexFun.call(bucketList.first.first), valueFun.call(bucketList.first.first)];

    List<T> resultList = [bucketList.first.first];
    for (int i = 1; i < bucketList.length - 1; i++) {
      var bucket = bucketList[i];
      var nextBucket = bucketList[i + 1];
      var nextAve = aveBucket(nextBucket);
      var t = findData(preBucket, bucket, nextAve);
      resultList.add(t);
      preBucket = [indexFun.call(t), valueFun.call(t)];
    }
    resultList.add(sortList.last);
    return resultList;
  }

  T findData(List<num> pre, List<T> bucket, List<num> next) {
    T? result;
    num mv = 0;
    for (var i = 0; i < bucket.length; i++) {
      var t = bucket[i];
      var area = computeArea(pre, [indexFun.call(t), valueFun.call(t)], next);
      if (i == 0) {
        result = t;
        mv = area;
      } else {
        if (area > mv) {
          mv = area;
          result = t;
        }
      }
    }
    return result!;
  }

  List<num> aveBucket(List<T> bucket) {
    num v = 0;
    num t = 0;
    for (var data in bucket) {
      v += valueFun.call(data);
      t += indexFun.call(data);
    }
    return [t / bucket.length, v / bucket.length];
  }

  num computeArea(List<num> a, List<num> b, List<num> c) {
    var x1 = b[0] - a[0].toDouble();
    var y1 = b[1] - a[1].toDouble();
    var x2 = c[0] - a[0].toDouble();
    var y2 = c[1] - a[1].toDouble();
    return (x1 * y2 - x2 * y1) / 2;
  }
}
