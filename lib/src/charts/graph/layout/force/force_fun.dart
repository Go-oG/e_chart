
import '../../model/graph_node.dart';

typedef ForceFun<T extends GraphNode> = num Function(T node, int i, List<T>, num width, num height);
