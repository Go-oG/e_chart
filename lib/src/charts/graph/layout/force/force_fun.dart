
import '../../graph_data.dart';

typedef ForceFun<T extends GraphData> = num Function(T node, int i, List<T>, num width, num height);
