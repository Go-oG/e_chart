import 'layout_node.dart';

abstract class SankeyAlign {
  const SankeyAlign();
  int align(SankeyNode node, int n);
}

class LeftAlign extends SankeyAlign {
  const LeftAlign();
  @override
  int align(SankeyNode node, int n) {
    return node.depth;
  }
}

class RightAlign extends SankeyAlign {
  const RightAlign();
  @override
  int align(SankeyNode node, int n) {
    return (n - 1 - node.heightIndex);
  }
}

class JustifyAlign extends SankeyAlign {
  const JustifyAlign();
  @override
  int align(SankeyNode node, int n) {
    if (node.outLinks.isEmpty) {
      return n - 1;
    }
    return node.depth;
  }
}

class CenterAlign extends SankeyAlign {
  const CenterAlign();
  @override
  int align(SankeyNode node, int n) {
    if (node.inputLinks.isNotEmpty) {
      return node.depth;
    }
    if (node.outLinks.isNotEmpty) {
      int deep = node.outLinks[0].target.depth;
      for (var element in node.outLinks) {
        if (element.target.depth < deep) {
          deep = element.target.depth;
        }
      }
      return deep - 1;
    }

    return 0;
  }
}
