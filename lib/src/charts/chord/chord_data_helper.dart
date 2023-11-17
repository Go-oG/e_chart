import 'package:e_chart/e_chart.dart';

///负责处理数据
class ChordDataHelper {
  ///标识是否为有向
  final bool direction;
  late Map<ChordData, List<ChordLink>> outMap = {};
  late Map<ChordData, List<ChordLink>> innerMap = {};

  late List<ChordData> dataList = [];
  Fun3<ChordData, ChordData, int>? _sortFun;
  Fun3<ChordData, ChordData, int>? _linkSortFun;

  ChordDataHelper(
    List<ChordLink> data,
    this.direction, {
    Fun3<ChordData, ChordData, int>? sortFun,
    Fun3<ChordData, ChordData, int>? linkSortFun,
  }) {
    _sortFun = sortFun;
    _linkSortFun = linkSortFun;
    _handle(data);
  }

  void _handle(List<ChordLink> data) {
    Map<ChordData, List<ChordLink>> outMap = {};
    Map<ChordData, List<ChordLink>> innerMap = {};
    each(data, (link, p1) {
      var source = link.source;
      var target = link.target;
      //source-outer
      List<ChordLink> list = outMap[source] ?? [];
      outMap[source] = list;
      list.add(link);

      //target-inner
      list = innerMap[target] ?? [];
      innerMap[target] = list;
      list.add(link);

      if (!direction) {
        //source-inner
        list = innerMap[source] ?? [];
        innerMap[source] = list;
        list.add(link);

        //target-outer
        list = outMap[target] ?? [];
        outMap[target] = list;
        list.add(link);
      }
    });

    each(outMap.keys, (p0, p1) {
      p0.value = 0;
    });
    ///统计值
    each(data, (link, p1) {
      var source = link.source;
      var target = link.target;
      source.value += link.value;
      target.value += link.value;
    });

    var linkFun = _linkSortFun;
    if (linkFun != null) {
      outMap.forEach((key, value) {
        value.sort((a, b) {
          return linkFun.call(a.target, b.target);
        });
      });
    }
    List<ChordData> list = List.from(outMap.keys);
    var sortFun = _sortFun;
    if (sortFun != null) {
      list.sort(sortFun);
    }
    this.outMap = outMap;
    this.innerMap = innerMap;
    dataList = list;
  }
}
