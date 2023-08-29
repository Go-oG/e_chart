import 'sankey_node.dart';

abstract class SankeyAlign {
  const SankeyAlign();

  num align(SankeyNode node, int n);
}

class LeftAlign extends SankeyAlign {
  const LeftAlign();

  @override
  num align(SankeyNode node, int n) {
    return node.deep;
  }
}

class RightAlign extends SankeyAlign {
  const RightAlign();

  @override
  num align(SankeyNode node, int n) {
    return (n - 1 - node.graphHeight);
  }
}

class JustifyAlign extends SankeyAlign {
  const JustifyAlign();

  @override
  num align(SankeyNode node, int n) {
    if (node.outLinks.isEmpty) {
      return n - 1;
    }
    return node.deep;
  }
}

class CenterAlign extends SankeyAlign {
  const CenterAlign();

  @override
  num align(SankeyNode node, int n) {
    if (node.inputLinks.isNotEmpty) {
      return node.deep;
    }
    if (node.outLinks.isNotEmpty) {
      int deep = node.outLinks[0].target.deep;
      for (var element in node.outLinks) {
        if (element.target.deep < deep) {
          deep = element.target.deep;
        }
      }
      return deep - 1;
    }

    return 0;
  }
}
