import 'dart:ui';

import '../../../../core/index.dart';
import '../../../../model/string_number.dart';
import '../../index.dart';
import 'force_simulation.dart';

class ForceLayout extends GraphLayout {
  final List<Force> forces;
  List<SNumber> center;
  double alpha;
  double alphaMin;
  double? alphaDecay;
  double alphaTarget;
  double velocityDecay;
  bool optPerformance;
  ForceSimulation? _simulation;

  ForceLayout(
    this.forces, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.alpha = 1,
    this.alphaMin = 0.001,
    this.alphaDecay,
    this.alphaTarget = 0,
    this.velocityDecay = 0.1,
    this.optPerformance = false,
    super.nodeSpaceFun,
    super.sort,
  }) : super(workerThread: false);

  ForceLayout start() {
    _simulation?.start();
    return this;
  }

  ForceLayout restart() {
    _simulation?.restart();
    return this;
  }

  Offset _center = Offset.zero;

  @override
  Offset getTranslation() => _center;

  @override
  void onLayout(Graph graph, GraphLayoutParams params, LayoutType type) {
    _center = Offset(
      center[0].convert(params.width),
      center[1].convert(params.height),
    );
    if (_simulation == null) {
      _simulation = _initSimulation(params.context, graph, params.width, params.height);
      _simulation?.addListener(() {
        notifyLayoutUpdate();
      });
      _simulation?.onEnd = () {
        notifyLayoutEnd();
      };
    }
    start();
  }

  @override
  void stopLayout() {
    _simulation?.stop();
    _simulation?.dispose();
    _simulation = null;
    super.stopLayout();
  }

  @override
  void dispose() {
    _simulation?.dispose();
    _simulation = null;
    super.dispose();
  }

  ForceSimulation _initSimulation(Context context, Graph graph, num width, num height) {
    ForceSimulation simulation = ForceSimulation(context, graph);
    simulation.optPerformance = optPerformance;
    simulation.width = width;
    simulation.height = height;
    simulation.alpha(alpha);
    simulation.alphaMin(alphaMin);
    simulation.alphaTarget(alphaTarget);
    simulation.velocityDecay(velocityDecay);
    if (alphaDecay != null) {
      simulation.alphaDecay(alphaDecay!);
    }
    for (var f in forces) {
      simulation.addForce(f);
    }
    return simulation;
  }
}
