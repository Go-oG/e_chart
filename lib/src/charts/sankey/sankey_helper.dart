import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///布局参考：Ref:https://github.com/d3/d3-sankey/blob/master/src/sankey.js
class SankeyHelper extends LayoutHelper3<SankeyData, SankeyLink, SankeySeries> {
  /// 整个视图区域坐标坐标
  double left = 0, top = 0, right = 1, bottom = 1;
  double animationProcess = 1;
  num _nodeGap = 0;

  final RBush<SankeyData> _nodeBush =
      RBush((p0) => p0.attr.left, (p0) => p0.attr.top, (p0) => p0.attr.right, (p0) => p0.attr.bottom);

  final RBush<SankeyLink> _linkBush = RBush(
    (p0) => m.min(p0.source.attr.left, p0.target.attr.left),
    (p0) => m.min(p0.source.attr.top, p0.target.attr.top),
    (p0) => m.max(p0.source.attr.right, p0.target.attr.right),
    (p0) => m.max(p0.source.attr.bottom, p0.target.attr.bottom),
  );

  SankeyHelper(super.context, super.view, super.series) {
    _nodeGap = series.gap;
  }

  @override
  void onLayout(LayoutType type) {
    left = top = 0;
    right = view.width;
    bottom = view.height;
    oldHoverData = null;
    oldHoverLink = null;
    var dataList = [...series.data];
    var linkList = [...series.links];
    dataList = initData(dataList, linkList, 0);
    layoutNode(dataList, linkList);
    _nodeBush.clear().addAll(dataList);
    _linkBush.clear().addAll(linkList);

    ///动画
    var animation = getAnimation(type, 1);
    if (animation == null) {
      animationProcess = 1;
      dataSet = dataList;
      linkSet = linkList;
      return;
    }

    var dt = ChartDoubleTween(option: animation);
    animationProcess = 0;
    dt.addStartListener(() {
      dataSet = dataList;
      linkSet = linkList;
      inAnimation = true;
    });
    dt.addListener(() {
      animationProcess = dt.value;
      notifyLayoutUpdate();
    });
    dt.addEndListener(() {
      inAnimation = false;
    });
    context.addAnimationToQueue([AnimationNode(dt, animation, LayoutType.layout)]);
  }

  void layoutNode(List<SankeyData> nodes, List<SankeyLink> links) {
    _computeNodeLinks(nodes, links);
    _computeNodeValues(nodes);
    _computeNodeDeep(nodes);
    _computeNodeHeights(nodes);
    _computeNodeBreadths(nodes);
    _computeLinkBreadths(nodes);
    _computeLinkPosition(links, nodes);
  }

  @override
  SankeyData? findData(Offset offset) {
    var sr = Rect.fromCenter(center: offset, width: 1, height: 1);
    return _nodeBush.searchSingle(sr, (node) => node.contains(offset));
  }

  @override
  SankeyLink? findLink(Offset offset) {
    var sr = Rect.fromCenter(center: offset, width: 1, height: 1);
    var searchList = _linkBush.search2(sr);
    searchList.removeWhere((element) => !element.contains(offset));
    if (searchList.isEmpty) {
      return null;
    }
    SankeyLink result = searchList.first;
    if (searchList.length == 1) {
      return result;
    }
    for (var i = 1; i < searchList.length; i++) {
      var next = searchList[i];
      num sub = next.attr.width - result.attr.width;
      if (sub.abs() <= 1e-6) {
        sub = 0;
      }
      if (sub < 0) {
        result = next;
      } else if (sub == 0) {
        if ((next.target.attr.left - next.source.attr.right) < (result.target.attr.left - next.source.attr.right)) {
          result = next;
        }
      }
    }
    return result;
  }

  /// 计算链接位置
  void _computeLinkPosition(List<SankeyLink> links, List<SankeyData> nodes) {
    for (var node in nodes) {
      node.attr.rect = Rect.fromLTRB(node.attr.left, node.attr.top, node.attr.right, node.attr.bottom);
      if (node.attr.rect.hasNaN) {
        throw ChartError('$node ${node.attr.rect}');
      }
    }
    for (var link in links) {
      link.computeAreaPath(series.smooth);
    }
  }

  void _computeNodeLinks(List<SankeyData> nodes, List<SankeyLink> links) {
    each(nodes, (p0, p1) {
      p0.attr.index = p1;
    });
    each(links, (link, i) {
      link.attr.index = i;
      link.source.attr.outLinks.add(link);
      link.target.attr.inputLinks.add(link);
    });

    if (series.linkSort != null) {
      for (var element in nodes) {
        element.attr.outLinks.sort(series.linkSort);
        element.attr.inputLinks.sort(series.linkSort);
      }
    }
  }

  ///计算节点数值(统计流入和流出取最大值)
  void _computeNodeValues(List<SankeyData> nodes) {
    for (var node in nodes) {
      if (node.fixedValue != null) {
        node.attr.value = node.fixedValue!;
        continue;
      }
      num sv = sumBy(node.attr.inputLinks, (p0) => p0.value);
      num tv = sumBy(node.attr.outLinks, (p0) => p0.value);
      node.attr.value = m.max(sv, tv);
    }
  }

  ///计算节点图深度
  ///同时判断是否存在环路
  void _computeNodeDeep(List<SankeyData> nodes) {
    int n = nodes.length;
    Set<SankeyData> current = Set.from(nodes);
    Set<SankeyData> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.attr.deep = x;
        for (var element in node.attr.outLinks) {
          next.add(element.target);
        }
      }
      if (++x > n) {
        throw ChartError("circular link");
      }
      current = next;
      next = {};
    }
  }

  ///计算节点图高度(同时判断是否存在环路)
  void _computeNodeHeights(List<SankeyData> nodes) {
    int n = nodes.length;
    Set<SankeyData> current = Set.from(nodes);
    Set<SankeyData> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.attr.graphHeight = x;
        for (var link in node.attr.inputLinks) {
          next.add(link.source);
        }
      }
      x += 1;
      if (x > n) throw ChartError("circular link");
      current = next;
      next = {};
    }
  }

  ///计算节点层次结构用于确定横向坐标
  List<List<SankeyData>> _computeNodeLayers(List<SankeyData> nodes) {
    int x = maxBy<SankeyData>(nodes, (p0) => p0.attr.deep).attr.deep + 1;
    double kx = (right - left - series.nodeWidth) / (x - 1);

    List<List<SankeyData>> columns = List.generate(x, (index) => []);

    for (var node in nodes) {
      int i = m.max(0, m.min(x - 1, series.align.align(node, x).floor()));
      node.attr.layer = i;
      node.attr.left = left + i * kx;
      node.attr.right = node.attr.left + series.nodeWidth;
      columns[i].add(node);
    }
    if (series.nodeSort != null) {
      for (var column in columns) {
        column.sort(series.nodeSort);
      }
    }
    return columns;
  }

  ///初始化给定列数的每个节点的高度
  void _initializeNodeBreadths(List<List<SankeyData>> columns) {
    //计算比例尺
    double ky = minBy2<List<SankeyData>>(columns, (c) {
      var v = (bottom - top - (c.length - 1) * _nodeGap);
      var sv = sumBy<SankeyData>(c, (p0) => p0.attr.value);
      return v / sv;
    }).toDouble();
    if (ky.isNaN || ky.isInfinite) {
      Logger.w("比例尺计算异常 ky=$ky,将固定比例尺");
      ky = 0.3;
    }

    for (var nodes in columns) {
      double y = top;
      for (var node in nodes) {
        node.attr.top = y;
        node.attr.bottom = y + node.attr.value * ky;
        y = node.attr.bottom + _nodeGap;
        for (var link in node.attr.outLinks) {
          link.attr.width = link.value * ky;
        }
      }

      y = (bottom - y + _nodeGap) / (nodes.length + 1);
      each(nodes, (node, i) {
        node.attr.top += y * (i + 1);
        node.attr.bottom += y * (i + 1);
      });
      _reorderLinks(nodes);
    }
  }

  ///计算节点高度(多次迭代)
  void _computeNodeBreadths(List<SankeyData> nodes) {
    List<List<SankeyData>> columns = _computeNodeLayers(nodes);

    ///计算节点间距(目前可能不需要，因为series已经定义了)
    num dy = 8;
    _nodeGap = m.min(dy, (bottom - top) / (maxBy2(columns, (c) => c.length) - 1));

    _initializeNodeBreadths(columns);
    int iterations = series.iterationCount;
    for (int i = 0; i < iterations; ++i) {
      double alpha = m.pow(0.99, i).toDouble();
      double beta = m.max(1 - alpha, (i + 1) / iterations);
      _relaxRightToLeft(columns, alpha, beta);
      _relaxLeftToRight(columns, alpha, beta);
    }
  }

  /// 根据传入目标链接重新定位每个节点
  void _relaxLeftToRight(List<List<SankeyData>> columns, double alpha, double beta) {
    each(columns, (column, i) {
      for (var target in column) {
        num y = 0;
        num w = 0;
        for (var link in target.attr.inputLinks) {
          num v = link.value * (target.attr.layer - link.source.attr.layer);
          y += _targetTop(link.source, target) * v;
          w += v;
        }
        if (w <= 0) {
          continue;
        }
        double dy = (y / w - target.attr.top) * alpha;
        target.attr.top += dy;
        target.attr.bottom += dy;
        _reorderNodeLinks(target);
      }
      if (series.nodeSort == null) {
        column.sort(_ascBreadth);
      }
      _resolveCollisions(column, beta);
    });
  }

  ///根据传入目标链接重新定位每个节点
  void _relaxRightToLeft(List<List<SankeyData>> columns, double alpha, double beta) {
    for (int n = columns.length, i = n - 2; i >= 0; --i) {
      var column = columns[i];
      for (var source in column) {
        double y = 0;
        double w = 0;
        for (var link in source.attr.outLinks) {
          num v = link.value * (link.target.attr.layer - source.attr.layer);
          y += _sourceTop(source, link.target) * v;
          w += v;
        }
        if (w <= 0) {
          continue;
        }
        double dy = (y / w - source.attr.top) * alpha;
        source.attr.top += dy;
        source.attr.bottom += dy;
        _reorderNodeLinks(source);
      }
      if (series.nodeSort == null) {
        column.sort(_ascBreadth);
      }
      _resolveCollisions(column, beta);
    }
  }

  void _resolveCollisions(List<SankeyData> nodes, double alpha) {
    if (nodes.isEmpty) {
      return;
    }
    int i = nodes.length >> 1;

    /// 算数右移
    var subject = nodes[i];
    _resolveCollisionsBottomToTop(nodes, subject.attr.top - _nodeGap, i - 1, alpha);
    _resolveCollisionsTopToBottom(nodes, subject.attr.bottom + _nodeGap, i + 1, alpha);
    _resolveCollisionsBottomToTop(nodes, bottom, nodes.length - 1, alpha);
    _resolveCollisionsTopToBottom(nodes, top, 0, alpha);
  }

  ///向下推任何重叠的节点
  void _resolveCollisionsTopToBottom(List<SankeyData> nodes, double y, int arrayIndex, double alpha) {
    for (; arrayIndex < nodes.length; ++arrayIndex) {
      var node = nodes[arrayIndex];
      var dy = (y - node.attr.top) * alpha;
      if (dy > 1e-6) {
        node.attr.top += dy;
        node.attr.bottom += dy;
      }
      y = node.attr.bottom + _nodeGap;
    }
  }

  ///向上推任何重叠的节点。
  void _resolveCollisionsBottomToTop(List<SankeyData> nodes, double y, int arrayIndex, double alpha) {
    for (; arrayIndex >= 0; --arrayIndex) {
      var node = nodes[arrayIndex];
      double dy = (node.attr.bottom - y) * alpha;
      if (dy > 1e-6) {
        node.attr.top -= dy;
        node.attr.bottom -= dy;
      }
      y = node.attr.top - _nodeGap;
    }
  }

  void _reorderNodeLinks(SankeyData node) {
    if (series.linkSort != null) {
      return;
    }

    for (var link in node.attr.inputLinks) {
      link.source.attr.outLinks.sort(_ascTargetBreadth);
    }
    for (var link in node.attr.outLinks) {
      link.target.attr.inputLinks.sort(_ascSourceBreadth);
    }
  }

  void _reorderLinks(List<SankeyData> nodes) {
    if (series.linkSort != null) {
      return;
    }
    for (var node in nodes) {
      node.attr.outLinks.sort(_ascTargetBreadth);
      node.attr.inputLinks.sort(_ascSourceBreadth);
    }
  }

  ///返回target.top，它将生成从源到目标的理想链接
  double _targetTop(SankeyData source, SankeyData target) {
    double y = source.attr.top - (source.attr.outLinks.length - 1) * _nodeGap / 2;
    for (var link in source.attr.outLinks) {
      if (link.target == target) {
        break;
      }
      y += link.attr.width + _nodeGap;
    }

    for (var link in target.attr.inputLinks) {
      if (link.source == source) {
        break;
      }
      y -= link.attr.width;
    }
    return y;
  }

  ///返回source.top，它将生成从源到目标的理想链接
  double _sourceTop(SankeyData source, SankeyData target) {
    double y = target.attr.top - (target.attr.inputLinks.length - 1) * _nodeGap / 2;
    for (var link in target.attr.inputLinks) {
      if (link.source == source) {
        break;
      }
      y += link.attr.width + _nodeGap;
    }
    for (var link in source.attr.outLinks) {
      if (link.target == target) {
        break;
      }
      y -= link.attr.width;
    }
    return y;
  }

  List<SankeyData> initData(List<SankeyData> dataList, List<SankeyLink> links, double nodeWidth) {
    Map<String, SankeyData> dataMap = {};
    each(dataList, (p0, p1) {
      dataMap[p0.id] = p0;
      p0.dataIndex = p1;
      p0.updateStyle(context, series);
    });
    int index = dataMap.length;

    each(links, (link, p1) {
      link.dataIndex = p1;
      var source = link.source;
      if (dataMap.containsKey(source.id)) {
        link.source = dataMap[source.id]!;
      } else {
        dataMap[source.id] = source;
        source.dataIndex = index;
        index++;
        source.updateStyle(context, series);
      }

      var target = link.target;
      if (dataMap.containsKey(target.id)) {
        link.target = dataMap[target.id]!;
      } else {
        dataMap[target.id] = target;
        target.dataIndex = index;
        index++;
        target.updateStyle(context, series);
      }
      link.updateStyle(context, series);
    });
    return List.from(dataMap.values);
  }

  @override
  List<SankeyLink> getDataInLink(SankeyData data) => data.attr.inputLinks;

  @override
  List<SankeyLink> getDataOutLink(SankeyData data) => data.attr.outLinks;

  @override
  SankeyData getLinkSource(SankeyLink link) => link.source;

  @override
  SankeyData getLinkTarget(SankeyLink link) => link.target;
}

int _ascSourceBreadth(SankeyLink a, SankeyLink b) {
  int ab = _ascBreadth(a.source, b.source);
  if (ab != 0) {
    return ab;
  }
  return (a.attr.index - b.attr.index);
}

int _ascTargetBreadth(SankeyLink a, SankeyLink b) {
  int ab = _ascBreadth(a.target, b.target);
  if (ab != 0) {
    return ab;
  }
  return (a.attr.index - b.attr.index);
}

int _ascBreadth(SankeyData a, SankeyData b) {
  return a.attr.top.compareTo(b.attr.top);
}

void _computeLinkBreadths(List<SankeyData> nodes) {
  for (var node in nodes) {
    double y0 = node.attr.top;

    for (var link in node.attr.outLinks) {
      link.attr.sourceY = y0;
      y0 += link.attr.width;
    }
    double y1 = node.attr.top;
    for (var link in node.attr.inputLinks) {
      link.attr.targetY = y1;
      y1 += link.attr.width;
    }
  }
}
