import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///Ref:https://github.com/d3/d3-sankey/blob/master/src/sankey.js
class SankeyHelper extends LayoutHelper<SankeySeries> {
  /// 整个视图区域坐标坐标
  double left = 0, top = 0, right = 1, bottom = 1;
  List<SankeyNode> _nodes = [];

  List<SankeyNode> get nodes => _nodes;

  List<SankeyLink> _links = [];

  List<SankeyLink> get links => _links;

  num _nodeGap = 0;

  SankeyHelper(super.context, super.series) {
    _nodeGap = series.gap;
  }

  @override
  void onLayout(LayoutType type) {
    left = 0;
    top = 0;
    right = width;
    bottom = height;
    layoutNode();
  }

  void layoutNode() {
    _nodes = [];
    _links = [];
    _nodes.addAll(buildNodes(series.data.data, series.data.links, 0));
    _links.addAll(buildLink(_nodes, series.data.links));
    _computeNodeLinks(_nodes, _links);
    _computeNodeValues(_nodes);
    _computeNodeDeep(_nodes);
    _computeNodeHeights(_nodes);
    _computeNodeBreadths(_nodes);
    _computeLinkBreadths(_nodes);
    _computeLinkPosition(_links, _nodes);
  }

  void update(List<SankeyNode> nodes) {
    _computeLinkBreadths(nodes);
    _computeLinkPosition(links, nodes);
  }

  AreaStyle? getAreaStyle(SankeyNode node) {
    var fun = series.areaStyleFun;
    if (fun != null) {
      return fun.call(node.data, node.dataIndex, node.status);
    }
    return context.option.theme.getAreaStyle(node.dataIndex).convert(node.status);
  }

  LineStyle? getBorderStyle(SankeyNode node) {
    var fun = series.borderStyleFun;
    if (fun != null) {
      return fun.call(node.data, node.dataIndex, node.status);
    }
    return context.option.theme.sankeyTheme.getStyle()?.convert(node.status);
  }

  AreaStyle getLinkStyle(SankeyNode source, SankeyNode target) {
    var fun = series.linkStyleFun;
    if (fun != null) {
      return fun.call(source.data, source.dataIndex, source.status, target.data, target.dataIndex, target.status);
    }
    var color = context.option.theme.sankeyTheme.linkColor;
    if (color != null) {
      return AreaStyle(color: context.option.theme.sankeyTheme.color);
    }
    var as = getAreaStyle(source)?.color;
    var ae = getAreaStyle(target)?.color;
    if (as != null && ae != null) {
      if (!source.isDisabled && !target.isDisabled) {
        return AreaStyle(shader: LineShader([as.withOpacity(0.5), ae.withOpacity(0.5)]));
      }
    }
    return AreaStyle(color: Colors.grey.withOpacity(0.5));
  }

  @override
  void onClick(Offset localOffset) {
    handleHoverAndClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    handleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    handleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverEnd() {
    _handleCancel();
  }

  SankeyNode? _oldHoverNode;
  SankeyLink? _oldHoverLink;

  void handleHoverAndClick(Offset local, bool click) {
    dynamic clickNode = findEventNode(local);
    if (clickNode == null) {
      _handleCancel();
      return;
    }

    var oldLink = _oldHoverLink;
    _oldHoverLink = null;
    var oldNode = _oldHoverNode;
    _oldHoverNode = null;

    if (clickNode == oldNode || clickNode == oldLink) {
      return;
    }

    if (clickNode is SankeyLink) {
      SankeyLink link = clickNode;
      _oldHoverLink = link;
      changeNodeStatus(null, link);
      notifyLayoutUpdate();
      return;
    }
    if (clickNode is SankeyNode) {
      SankeyNode node = clickNode;
      _oldHoverNode = node;
      changeNodeStatus(node, null);
      notifyLayoutUpdate();
      return;
    }
  }

  void _handleCancel() {
    bool hasChange = false;
    if (_oldHoverLink != null) {
      _oldHoverLink?.removeStates([ViewState.selected, ViewState.hover]);
      _oldHoverLink = null;
      hasChange = true;
    }
    if (_oldHoverNode != null) {
      _oldHoverNode?.removeStates([ViewState.selected, ViewState.hover]);
      _oldHoverNode = null;
      hasChange = true;
    }
    if (hasChange) {
      resetDataStatus();
      notifyLayoutUpdate();
    }
  }

  ///找到点击节点(优先节点而不是边)
  dynamic findEventNode(Offset offset) {
    for (var ele in _nodes) {
      if (ele.rect.contains2(offset)) {
        return ele;
      }
    }
    for (var element in _links) {
      if (element.area.toPath(true).contains(offset)) {
        return element;
      }
    }

    return null;
  }

  //处理数据状态
  void changeNodeStatus(SankeyNode? node, SankeyLink? link) {
    Set<SankeyLink> linkSet = {};
    Set<SankeyNode> nodeSet = {};
    if (link != null) {
      linkSet.add(link);
      nodeSet.add(link.target);
      nodeSet.add(link.source);
    }

    if (node != null) {
      nodeSet.add(node);
      linkSet.addAll(node.inputLinks);
      linkSet.addAll(node.outLinks);
      for (var element in node.inputLinks) {
        nodeSet.add(element.source);
      }
      for (var element in node.outLinks) {
        nodeSet.add(element.target);
      }
    }

    bool hasSelect = linkSet.isNotEmpty || nodeSet.isNotEmpty;
    var status = [ViewState.hover, ViewState.selected];

    for (var ele in _links) {
      ele.cleanState();
      if (!hasSelect) {
        continue;
      }

      if (nodeSet.contains(ele.target) && nodeSet.contains(ele.source)) {
        ele.addStates(status);
      } else {
        ele.addState(ViewState.disabled);
      }
    }

    for (var ele in _nodes) {
      ele.cleanState();
      if (!hasSelect) {
        continue;
      }

      if (nodeSet.contains(ele)) {
        ele.addStates(status);
      } else {
        ele.addState(ViewState.disabled);
      }
    }
  }

  /// 重置数据状态
  void resetDataStatus() {
    for (var ele in _links) {
      ele.cleanState();
    }
    for (var ele in _nodes) {
      ele.cleanState();
    }
  }

  @override
  SeriesType get seriesType => SeriesType.sankey;

  /// 计算链接位置
  void _computeLinkPosition(List<SankeyLink> links, List<SankeyNode> nodes) {
    for (var node in nodes) {
      node.rect = Rect.fromLTRB(node.left, node.top, node.right, node.bottom);
    }
    for (var link in links) {
      link.computeAreaPath(series.smooth);
    }
  }

  void _computeNodeLinks(List<SankeyNode> nodes, List<SankeyLink> links) {
    each(nodes, (p0, p1) {
      p0.index = p1;
    });
    each(links, (link, i) {
      link.index = i;
      link.source.outLinks.add(link);
      link.target.inputLinks.add(link);
    });

    if (series.linkSort != null) {
      for (var element in nodes) {
        element.outLinks.sort(series.linkSort);
        element.inputLinks.sort(series.linkSort);
      }
    }
  }

  ///计算节点数值(统计流入和流出取最大值)
  void _computeNodeValues(List<SankeyNode> nodes) {
    for (var node in nodes) {
      if (node.fixedValue != null) {
        node.value = node.fixedValue!;
        continue;
      }
      num sv = sumBy(node.inputLinks, (p0) => p0.value);
      num tv = sumBy(node.outLinks, (p0) => p0.value);
      node.value = m.max(sv, tv);
    }
  }

  ///计算节点图深度
  ///同时判断是否存在环路
  void _computeNodeDeep(List<SankeyNode> nodes) {
    int n = nodes.length;
    Set<SankeyNode> current = Set.from(nodes);
    Set<SankeyNode> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.deep = x;
        for (var element in node.outLinks) {
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
  void _computeNodeHeights(List<SankeyNode> nodes) {
    int n = nodes.length;
    Set<SankeyNode> current = Set.from(nodes);
    Set<SankeyNode> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.graphHeight = x;
        for (var link in node.inputLinks) {
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
  List<List<SankeyNode>> _computeNodeLayers(List<SankeyNode> nodes) {
    int x = maxBy<SankeyNode>(nodes, (p0) => p0.deep).deep + 1;
    double kx = (right - left - series.nodeWidth) / (x - 1);

    List<List<SankeyNode>> columns = List.generate(x, (index) => []);

    for (var node in nodes) {
      int i = m.max(0, m.min(x - 1, series.align.align(node, x).floor()));
      node.layer = i;
      node.left = left + i * kx;
      node.right = node.left + series.nodeWidth;
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
  void _initializeNodeBreadths(List<List<SankeyNode>> columns) {
    //计算比例尺
    double ky = minBy2<List<SankeyNode>>(columns, (c) {
      var v = (bottom - top - (c.length - 1) * _nodeGap);
      var sv = sumBy<SankeyNode>(c, (p0) => p0.value);
      return v / sv;
    }).toDouble();
    for (var nodes in columns) {
      double y = top;
      for (var node in nodes) {
        node.top = y;
        node.bottom = y + node.value * ky;
        y = node.bottom + _nodeGap;
        for (var link in node.outLinks) {
          link.width = link.value * ky;
        }
      }

      y = (bottom - y + _nodeGap) / (nodes.length + 1);
      each(nodes, (node, i) {
        node.top += y * (i + 1);
        node.bottom += y * (i + 1);
      });
      _reorderLinks(nodes);
    }
  }

  ///计算节点高度(多次迭代)
  void _computeNodeBreadths(List<SankeyNode> nodes) {
    List<List<SankeyNode>> columns = _computeNodeLayers(nodes);

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
  void _relaxLeftToRight(List<List<SankeyNode>> columns, double alpha, double beta) {
    each(columns, (column, i) {
      for (var target in column) {
        num y = 0;
        num w = 0;
        for (var link in target.inputLinks) {
          num v = link.value * (target.layer - link.source.layer);
          y += _targetTop(link.source, target) * v;
          w += v;
        }
        if (w <= 0) {
          continue;
        }
        double dy = (y / w - target.top) * alpha;
        target.top += dy;
        target.bottom += dy;
        _reorderNodeLinks(target);
      }
      if (series.nodeSort == null) {
        column.sort(_ascBreadth);
      }
      _resolveCollisions(column, beta);
    });
  }

  ///根据传入目标链接重新定位每个节点
  void _relaxRightToLeft(List<List<SankeyNode>> columns, double alpha, double beta) {
    for (int n = columns.length, i = n - 2; i >= 0; --i) {
      var column = columns[i];
      for (var source in column) {
        double y = 0;
        double w = 0;
        for (var link in source.outLinks) {
          num v = link.value * (link.target.layer - source.layer);
          y += _sourceTop(source, link.target) * v;
          w += v;
        }
        if (w <= 0) {
          continue;
        }
        double dy = (y / w - source.top) * alpha;
        source.top += dy;
        source.bottom += dy;
        _reorderNodeLinks(source);
      }
      if (series.nodeSort == null) {
        column.sort(_ascBreadth);
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

  ///向下推任何重叠的节点
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

  ///向上推任何重叠的节点。
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

  void _reorderNodeLinks(SankeyNode node) {
    if (series.linkSort != null) {
      return;
    }

    for (var link in node.inputLinks) {
      link.source.outLinks.sort(_ascTargetBreadth);
    }
    for (var link in node.outLinks) {
      link.target.inputLinks.sort(_ascSourceBreadth);
    }
  }

  void _reorderLinks(List<SankeyNode> nodes) {
    if (series.linkSort != null) {
      return;
    }
    for (var node in nodes) {
      node.outLinks.sort(_ascTargetBreadth);
      node.inputLinks.sort(_ascSourceBreadth);
    }
  }

  ///返回target.top，它将生成从源到目标的理想链接
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

  ///返回source.top，它将生成从源到目标的理想链接
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

  static List<SankeyNode> buildNodes(List<ItemData> dataList, List<SankeyLinkData> links, double nodeWidth) {
    List<SankeyNode> resultList = [];
    Set<ItemData> dataSet = {};
    each(dataList, (data, i) {
      if (dataSet.contains(data)) {
        return;
      }
      dataSet.add(data);
      SankeyNode layoutNode = SankeyNode(data, [], [], i);
      resultList.add(layoutNode);
    });

    int index = dataList.length;

    for (var link in links) {
      if (!dataSet.contains(link.src)) {
        dataSet.add(link.src);
        SankeyNode layoutNode = SankeyNode(link.src, [], [], index);
        index += 1;
        resultList.add(layoutNode);
      }
      if (!dataSet.contains(link.target)) {
        dataSet.add(link.target);
        SankeyNode layoutNode = SankeyNode(link.target, [], [], index);
        index += 1;
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
}

int _ascSourceBreadth(SankeyLink a, SankeyLink b) {
  int ab = _ascBreadth(a.source, b.source);
  if (ab != 0) {
    return ab;
  }
  return (a.index - b.index);
}

int _ascTargetBreadth(SankeyLink a, SankeyLink b) {
  int ab = _ascBreadth(a.target, b.target);
  if (ab != 0) {
    return ab;
  }
  return (a.index - b.index);
}

int _ascBreadth(SankeyNode a, SankeyNode b) {
  return a.top.compareTo(b.top);
}

void _computeLinkBreadths(List<SankeyNode> nodes) {
  for (var node in nodes) {
    double y0 = node.top;

    for (var link in node.outLinks) {
      link.sourceY = y0;
      y0 += link.width;
    }
    double y1 = node.top;
    for (var link in node.inputLinks) {
      link.targetY = y1;
      y1 += link.width;
    }
  }
}
