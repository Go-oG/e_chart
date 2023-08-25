import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///Ref:https://github.com/d3/d3-sankey/blob/master/src/sankey.js
class SankeyLayout extends LayoutHelper<SankeySeries> {
  /// 整个视图区域坐标坐标
  double left = 0, top = 0, right = 1, bottom = 1;
  double _nodeWidth = 24;
  double _nodeGap = 0;
  SankeyAlign _align = const JustifyAlign();
  NodeSort? _nodeSort;
  LinkSort? _linkSort;
  int _iterations = 6;

  List<SankeyNode> _nodes = [];
  List<SankeyLink> _links = [];

  SankeyLayout(super.context, super.series) {
    _nodeWidth = series.nodeWidth;
    _nodeGap = series.gap;
    _align = series.align;
    _nodeSort = series.nodeSort;
    _linkSort = series.linkSort;
    _iterations = series.iterationCount;
  }

  @override
  void onLayout(LayoutType type) {
    left = 0;
    top = 0;
    right = width;
    bottom = height;
    _nodes = [];
    _links = [];
    _nodes.addAll(buildNodes(series.data.data, series.data.links, 0));
    _links.addAll(buildLink(_nodes, series.data.links));

    _computeNodeLinks(_nodes, _links);
    _computeNodeValues(_nodes);
    _computeNodeDepths(_nodes);
    _computeNodeHeights(_nodes);
    _computeNodeBreadths(_nodes);
    _computeLinkBreadths(_nodes);
    _computeLinkPosition(_links, _nodes);
  }

  @override
  SeriesType get seriesType => SeriesType.sankey;

  /// 计算链接位置
  void _computeLinkPosition(List<SankeyLink> links, List<SankeyNode> nodes) {
    for (var node in nodes) {
      node.rect = Rect.fromLTRB(node.left, node.top, node.right, node.bottom);
    }

    for (var node in nodes) {
      List<SankeyLink> targetLinks = [...node.outLinks];
      if (targetLinks.isEmpty) {
        continue;
      }

      targetLinks.sort((a, b) {
        return a.target.top.compareTo(b.target.top);
      });

      double topOffset = node.top;
      for (var link in targetLinks) {
        link.leftTop = Offset(link.source.right, topOffset);
        link.leftBottom = Offset(link.source.right, topOffset + link.width);
        topOffset += link.width;
      }
    }
    for (var node in nodes) {
      List<SankeyLink> sourceLinks = [...node.inputLinks];
      if (sourceLinks.isEmpty) {
        continue;
      }
      sourceLinks.sort((a, b) {
        return a.source.top.compareTo(b.source.top);
      });
      double topOffset = node.top;
      for (var link in sourceLinks) {
        link.rightTop = Offset(node.left, topOffset);
        link.rightBottom = Offset(node.left, topOffset + link.width);
        topOffset += link.width;
      }
    }

    for (var link in links) {
      Offset o1 = Offset(link.leftTop.dx - 1, link.leftTop.dy);
      Offset o2 = Offset(link.rightTop.dx + 1, link.rightTop.dy);
      Line line = Line([o1, o2]);
      Path path = line.toPath(false);
      Matrix4 matrix4 = Matrix4.translationValues(0, m.max(1, link.width), 0);
      Path path2 = path.transform(matrix4.storage);
      link.path = path.mergePath(path2);
    }
  }

  void update(List<SankeyNode> nodes) {
    _computeLinkBreadths(nodes);
  }

  List<SankeyNode> get nodes => _nodes;

  List<SankeyLink> get links => _links;

  set nodeSort(NodeSort sort) {
    _nodeSort = sort;
  }

  set linkSort(LinkSort sort) {
    _linkSort = sort;
  }

  set nodeWidth(double w) {
    _nodeWidth = w;
  }

  set nodeGap(double gap) {
    _nodeGap = gap;
  }

  set iterations(int count) {
    _iterations = count;
  }

  static List<SankeyNode> buildNodes(List<ItemData> dataList, List<SankeyLinkData> links, double nodeWidth) {
    List<SankeyNode> resultList = [];
    Set<ItemData> dataSet = {};
    for (var data in dataList) {
      if (dataSet.contains(data)) {
        continue;
      }
      dataSet.add(data);
      SankeyNode layoutNode = SankeyNode(data, [], []);
      resultList.add(layoutNode);
    }
    for (var link in links) {
      if (!dataSet.contains(link.src)) {
        dataSet.add(link.src);
        SankeyNode layoutNode = SankeyNode(link.src, [], []);
        resultList.add(layoutNode);
      }
      if (!dataSet.contains(link.target)) {
        dataSet.add(link.target);
        SankeyNode layoutNode = SankeyNode(link.target, [], []);
        resultList.add(layoutNode);
      }
    }
    return resultList;
  }

  static List<SankeyLink> buildLink(List<SankeyNode> nodes, List<SankeyLinkData> links) {
    Map<String, SankeyNode> nodeMap = {};
    for (var element in nodes) {
      nodeMap[element.data.id] = element;
    }
    List<SankeyLink> resultList = [];
    for (var link in links) {
      SankeyNode srcNode = nodeMap[link.src.id]!;
      SankeyNode targetNode = nodeMap[link.target.id]!;
      resultList.add(SankeyLink(srcNode, targetNode, link.value));
    }
    return resultList;
  }

  void _computeNodeLinks(List<SankeyNode> nodes, List<SankeyLink> links) {
    for (int i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      node.index = i;
    }

    for (int i = 0; i < links.length; i++) {
      var link = links[i];
      link.index = i;
      link.source.outLinks.add(link);
      link.target.inputLinks.add(link);
    }
    if (_linkSort != null) {
      for (var element in nodes) {
        element.outLinks.sort(_linkSort);
        element.inputLinks.sort(_linkSort);
      }
    }
  }

  void _computeNodeDepths(List<SankeyNode> nodes) {
    int n = nodes.length;
    Set<SankeyNode> current = Set.from(nodes);
    Set<SankeyNode> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.depth = x;
        for (var element in node.outLinks) {
          next.add(element.target);
        }
      }
      if (++x > n) {
        throw FlutterError("circular link");
      }
      current = next;
      next = {};
    }
  }

  void _computeNodeValues(List<SankeyNode> nodes) {
    for (var node in nodes) {
      if (node.value != null) {
        continue;
      }
      double sv = 0;
      double tv = 0;
      for (var element in node.inputLinks) {
        sv += element.value;
      }
      for (var element in node.outLinks) {
        tv += element.value;
      }
      node.value = m.max(sv, tv);
    }
  }

  void _computeNodeHeights(List<SankeyNode> nodes) {
    int n = nodes.length;
    Set<SankeyNode> current = Set.from(nodes);
    Set<SankeyNode> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.heightIndex = x;
        for (var source in node.inputLinks) {
          next.add(source.source);
        }
      }
      x += 1;
      if (x > n) throw FlutterError("circular link");
      current = next;
      next = {};
    }
  }

  List<List<SankeyNode>> _computeNodeLayers(List<SankeyNode> nodes) {
    int x = _findMaxDeep(nodes) + 1;
    double kx = (right - left - _nodeWidth) / (x - 1);

    List<List<SankeyNode>> columns = List.generate(x, (index) => []);
    for (var node in nodes) {
      int i = m.max(0, m.min(x - 1, _align.align(node, x)));
      node.layerIndex = i;
      node.left = left + i * kx;
      node.right = node.left + _nodeWidth;
      columns[i].add(node);
    }
    if (_nodeSort != null) {
      for (var column in columns) {
        column.sort(_nodeSort);
      }
    }
    return columns;
  }

  void _initializeNodeBreadths(List<List<SankeyNode>> columns) {
    //计算比例尺
    double ky = double.infinity;
    for (var element in columns) {
      int cl = element.length;
      double v = 0;
      for (var e2 in element) {
        v += e2.value!;
      }

      double t = (bottom - top - (cl - 1) * _nodeGap) / v;
      if (t < ky) {
        ky = t;
      }
    }

    for (var nodes in columns) {
      double y = top;
      for (var node in nodes) {
        node.top = y;
        node.bottom = y + node.value! * ky;
        y = node.bottom + _nodeGap;
        for (var link in node.outLinks) {
          link.width = link.value * ky;
        }
      }

      y = (bottom - y + _nodeGap) / (nodes.length + 1);
      for (int i = 0; i < nodes.length; ++i) {
        var node = nodes[i];
        node.top += y * (i + 1);
        node.bottom += y * (i + 1);
      }
      _reorderLinks(nodes);
    }
  }

  void _computeNodeBreadths(List<SankeyNode> nodes) {
    List<List<SankeyNode>> columns = _computeNodeLayers(nodes);

    ///计算节点间距(目前不需要，因为series已经定义了)
    int maxLen = 0;
    for (var element in columns) {
      if (element.length > maxLen) {
        maxLen = element.length;
      }
    }
    double minNodeGap = 8;
    _nodeGap = m.min(minNodeGap, (bottom - top) / (maxLen - 1));

    _initializeNodeBreadths(columns);
    for (int i = 0; i < _iterations; ++i) {
      double alpha = m.pow(0.99, i).toDouble();
      double beta = m.max(1 - alpha, (i + 1) / _iterations);
      _relaxRightToLeft(columns, alpha, beta);
      _relaxLeftToRight(columns, alpha, beta);
    }
  }

  // Reposition each node based on its incoming (target) links.
  void _relaxLeftToRight(List<List<SankeyNode>> columns, alpha, beta) {
    for (int i = 1, n = columns.length; i < n; ++i) {
      var column = columns[i];
      for (var target in column) {
        double y = 0;
        double w = 0;
        for (var link in target.inputLinks) {
          double v = link.value * (target.layerIndex - link.source.layerIndex);
          y += _targetTop(link.source, target) * v;
          w += v;
        }
        if (!(w > 0)) {
          continue;
        }
        double dy = (y / w - target.top) * alpha;
        target.top += dy;
        target.bottom += dy;
        _reorderNodeLinks(target.outLinks, target.inputLinks);
      }
      if (_nodeSort == null) {
        column.sort(_ascendingBreadth);
      }
      _resolveCollisions(column, beta);
    }
  }

  // Reposition each node based on its outgoing (source) links.
  void _relaxRightToLeft(List<List<SankeyNode>> columns, double alpha, double beta) {
    for (int n = columns.length, i = n - 2; i >= 0; --i) {
      var column = columns[i];
      for (var source in column) {
        double y = 0;
        double w = 0;
        for (var link in source.outLinks) {
          double v = link.value * (link.target.layerIndex - source.layerIndex);
          y += _sourceTop(source, link.target) * v;
          w += v;
        }
        if (!(w > 0)) {
          continue;
        }
        double dy = (y / w - source.top) * alpha;
        source.top += dy;
        source.bottom += dy;
        _reorderNodeLinks(source.outLinks, source.inputLinks);
      }
      if (_nodeSort == null) {
        column.sort(_ascendingBreadth);
      }
      _resolveCollisions(column, beta);
    }
  }

  void _resolveCollisions(List<SankeyNode> nodes, double alpha) {
    if (nodes.isEmpty) {
      return;
    }
    int i = nodes.length >> 1;

    /// 算数右移

    var subject = nodes[i];
    _resolveCollisionsBottomToTop(nodes, subject.top - _nodeGap, i - 1, alpha);
    _resolveCollisionsTopToBottom(nodes, subject.bottom + _nodeGap, i + 1, alpha);
    _resolveCollisionsBottomToTop(nodes, bottom, nodes.length - 1, alpha);
    _resolveCollisionsTopToBottom(nodes, top, 0, alpha);
  }

  // Push any overlapping nodes down.
  void _resolveCollisionsTopToBottom(List<SankeyNode> nodes, double y, int arrayIndex, double alpha) {
    for (; arrayIndex < nodes.length; ++arrayIndex) {
      var node = nodes[arrayIndex];
      var dy = (y - node.top) * alpha;
      if (dy > 1e-6) {
        node.top += dy;
        node.bottom += dy;
      }
      y = node.bottom + _nodeGap;
    }
  }

  // Push any overlapping nodes up.
  void _resolveCollisionsBottomToTop(List<SankeyNode> nodes, double y, int arrayIndex, double alpha) {
    for (; arrayIndex >= 0; --arrayIndex) {
      var node = nodes[arrayIndex];
      double dy = (node.bottom - y) * alpha;
      if (dy > 1e-6) {
        node.top -= dy;
        node.bottom -= dy;
      }
      y = node.top - _nodeGap;
    }
  }

  void _reorderNodeLinks(List<SankeyLink> outLinks, List<SankeyLink> inputLinks) {
    if (_linkSort != null) {
      return;
    }

    for (var link in inputLinks) {
      link.source.outLinks.sort(_ascendingTargetBreadth);
    }
    for (var link in outLinks) {
      link.target.inputLinks.sort(_ascendingSourceBreadth);
    }
  }

  void _reorderLinks(List<SankeyNode> nodes) {
    if (_linkSort != null) {
      return;
    }
    for (var node in nodes) {
      node.outLinks.sort(_ascendingTargetBreadth);
      node.inputLinks.sort(_ascendingSourceBreadth);
    }
  }

  // Returns the target.y0 that would produce an ideal link from source to target.
  double _targetTop(SankeyNode source, SankeyNode target) {
    double y = source.top - (source.outLinks.length - 1) * _nodeGap / 2;
    for (var link in source.outLinks) {
      if (link.target == target) {
        break;
      }
      y += link.width + _nodeGap;
    }

    for (var link in target.inputLinks) {
      if (link.source == source) {
        break;
      }
      y -= link.width;
    }
    return y;
  }

  // Returns the source.y0 that would produce an ideal link from source to target.
  double _sourceTop(SankeyNode source, SankeyNode target) {
    double y = target.top - (target.inputLinks.length - 1) * _nodeGap / 2;
    for (var link in target.inputLinks) {
      if (link.source == source) {
        break;
      }
      y += link.width + _nodeGap;
    }
    for (var link in source.outLinks) {
      if (link.target == target) {
        break;
      }
      y -= link.width;
    }
    return y;
  }

  int _findMaxDeep(List<SankeyNode> list) {
    int deep = 0;
    for (var node in list) {
      if (node.depth > deep) {
        deep = node.depth;
      }
    }
    return deep;
  }
}

int _ascendingSourceBreadth(SankeyLink a, SankeyLink b) {
  int ab = _ascendingBreadth(a.source, b.source);
  return jsOr(ab, a.index - b.index).toInt();
}

int _ascendingTargetBreadth(SankeyLink a, SankeyLink b) {
  int ab = _ascendingBreadth(a.target, b.target);
  return jsAnd(ab, (a.index - b.index)).toInt();
}

int _ascendingBreadth(SankeyNode a, SankeyNode b) {
  return a.top.compareTo(b.top);
}

void _computeLinkBreadths(List<SankeyNode> nodes) {
  for (var node in nodes) {
    double y0 = node.top;
    double y1 = y0;
    for (var link in node.outLinks) {
      link.sourceY = y0 + link.width / 2;
      y0 += link.width;
    }

    for (var link in node.inputLinks) {
      link.targetY = y1 + link.width / 2;
      y1 += link.width;
    }
  }
}
