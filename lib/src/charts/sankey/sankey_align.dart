import 'sankey_data.dart';

abstract class SankeyAlign {
  const SankeyAlign();

  num align(SankeyData node, int n);
}

class LeftAlign extends SankeyAlign {
  const LeftAlign();

  @override
  num align(SankeyData node, int n) {
    return node.attr.deep;
  }
}

class RightAlign extends SankeyAlign {
  const RightAlign();

  @override
  num align(SankeyData node, int n) {
    return (n - 1 - node.attr.graphHeight);
  }
}

class JustifyAlign extends SankeyAlign {
  const JustifyAlign();

  @override
  num align(SankeyData node, int n) {
    if (node.attr.outLinks.isEmpty) {
      return n - 1;
    }
    return node.attr.deep;
  }
}

class CenterAlign extends SankeyAlign {
  const CenterAlign();

  @override
  num align(SankeyData node, int n) {
    if (node.attr.inputLinks.isNotEmpty) {
      return node.attr.deep;
    }
    if (node.attr.outLinks.isNotEmpty) {
      int deep = node.attr.outLinks[0].target.attr.deep;
      for (var element in node.attr.outLinks) {
        if (element.target.attr.deep < deep) {
          deep = element.target.attr.deep;
        }
      }
      return deep - 1;
    }

    return 0;
  }
}
