import '../../../model/index.dart';
import '../../style/index.dart';

/// 坐标轴指示器
class AxisPointer {
  bool show;

  ///触发条件
  TriggerOn triggerOn;
  //坐标轴指示器是否自动吸附到点上。默认自动判断
  bool? snap;

  LineStyle lineStyle;
  LabelStyle labelStyle;

  AxisPointer({
    this.show = true,
    this.snap,
    this.triggerOn = TriggerOn.moveAndClick,
    this.lineStyle = const LineStyle(),
    this.labelStyle = const LabelStyle(),
  });

}
