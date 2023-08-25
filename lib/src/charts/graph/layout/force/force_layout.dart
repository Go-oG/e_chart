import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
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
    super.nodeSize,
    super.sizeFun,
    super.nodeSpaceFun,
    super.sort,
    super.workerThread,
  });

  ForceLayout stop() {
    _simulation?.stop();
    return this;
  }

  ForceLayout start() {
    _simulation?.start();
    return this;
  }

  ForceLayout restart() {
    _simulation?.restart();
    return this;
  }

  @override
  void onLayout(LayoutType type) {
    stop();
    if (_simulation == null) {
      _simulation = _initSimulation(context, series.graph, width, height);
      _simulation?.addListener(() {
        if (hasInterrupted) {
          stop();
          return;
        }
        notifyLayoutUpdate();
      });
      _simulation?.onEnd = () {
        if (hasInterrupted) {
          stop();
          return;
        }
        notifyLayoutEnd();
      };
    }
    clearInterrupt();
    start();
  }

  @override
  void stopLayout() {
    stop();
  }

  @override
  void dispose() {
    _simulation?.dispose();
    _simulation = null;
    super.dispose();
  }

  @override
  Offset getTranslationOffset(num width, num height) {
    return Offset(center[0].convert(width), center[1].convert(height));
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
