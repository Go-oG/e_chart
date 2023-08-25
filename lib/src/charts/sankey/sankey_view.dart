import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'sankey_layout.dart';
import 'layout_node.dart';
import 'sankey_series.dart';

/// 桑基图
class SankeyView extends SeriesView<SankeySeries, SankeyLayout> {
  List<SankeyNode> _nodeList = [];
  List<SankeyLink> _linkList = [];
  SankeyLink? _link;
  SankeyNode? _node;

  SankeyView(super.series);

  @override
  void onClick(Offset offset) {
    _handleSelect(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _handleSelect(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _handleSelect(offset);
  }

  @override
  void onHoverEnd() {
    _handleCancel();
  }

  void _handleSelect(Offset local) {
    dynamic eventNode = findEventNode(local);
    if (eventNode == null) {
      _handleCancel();
      return;
    }
    if (eventNode is SankeyLink) {
      SankeyLink link = eventNode;
      if (link == _link) {
        return;
      }
      if (_node != null) {
        _node!.select = false;
        _node = null;
      }
      if (_link != null) {
        _link!.select = false;
      }
      _link = link;
      _handleDataStatus();
      invalidate();
      return;
    }
    if (eventNode is SankeyNode) {
      SankeyNode node = eventNode;
      if (node == _node) {
        return;
      }
      if (_link != null) {
        _link!.select = false;
        _link = null;
      }
      if (_node != null) {
        _node!.select = false;
      }
      _node = node;
      _handleDataStatus();
      invalidate();
      return;
    }
  }

  void _handleCancel() {
    bool hasChange = false;
    if (_link != null) {
      _link!.select = false;
      _link = null;
      hasChange = true;
    }
    if (_node != null) {
      _node!.select = false;
      _node = null;
      hasChange = true;
    }
    if (hasChange) {
      _resetDataStatus();
      invalidate();
    }
  }

  dynamic findEventNode(Offset offset) {
    for (var element in _linkList) {
      if (element.path.contains(offset)) {
        return element;
      }
    }
    for (var ele in _nodeList) {
      if (ele.rect.contains2(offset)) {
        return ele;
      }
    }
    return null;
  }

  //处理数据状态
  void _handleDataStatus() {
    Set<SankeyLink> linkSet = {};
    Set<SankeyNode> nodeSet = {};
    if (_link != null) {
      linkSet.add(_link!);
      nodeSet.add(_link!.target);
      nodeSet.add(_link!.source);
    }
    if (_node != null) {
      nodeSet.add(_node!);
      linkSet.addAll(_node!.inputLinks);
      linkSet.addAll(_node!.outLinks);
      for (var element in _node!.inputLinks) {
        nodeSet.add(element.source);
        nodeSet.add(element.target);
      }
      for (var element in _node!.outLinks) {
        nodeSet.add(element.source);
        nodeSet.add(element.target);
      }
    }

    for (var ele in _linkList) {
      if (linkSet.contains(ele)) {
        ele.colorAlpha = null;
      } else {
        ele.colorAlpha = 0.1;
      }
    }

    for (var ele in _nodeList) {
      if (nodeSet.contains(ele)) {
        ele.colorAlpha = null;
      } else {
        ele.colorAlpha = 0.1;
      }
    }
  }

  /// 重置数据状态
  void _resetDataStatus() {
    for (var ele in _linkList) {
      ele.colorAlpha = null;
      ele.select = false;
    }

    for (var ele in _nodeList) {
      ele.colorAlpha = null;
      ele.select = false;
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(selfBoxBound, globalBoxBound, LayoutType.layout);
    _nodeList = layoutHelper.nodes;
    _linkList = layoutHelper.links;
  }

  @override
  void onDraw(Canvas canvas) {
    _drawLink(canvas);
    for (var element in _nodeList) {
      AreaStyle style = series.nodeStyle.call(element.data);
      style.drawRect(canvas, mPaint, element.rect);
    }
  }

  void _drawLink(Canvas canvas) {
    AreaStyle tmpStyle = const AreaStyle(color: Colors.black26);
    for (var link in _linkList) {
      AreaStyle? style = series.linkStyleFun?.call(link.source.data, link.target.data);
      style ??= tmpStyle;
      style.drawPath(canvas, mPaint, link.path);
    }
  }

  @override
  SankeyLayout buildLayoutHelper() {
    return SankeyLayout(context, series);
  }
}
