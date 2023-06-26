import 'package:vector_math/vector_math.dart';

import '../chart_tween.dart';

class ChartMatrix4Tween extends ChartTween<Matrix4> {
  ChartMatrix4Tween(super.begin, super.end,{super.allowCross,super.props});
  @override
  Matrix4 convert(double animatorPercent) {
    double t = animatorPercent;
    final Vector3 beginTranslation = Vector3.zero();
    final Vector3 endTranslation = Vector3.zero();
    final Quaternion beginRotation = Quaternion.identity();
    final Quaternion endRotation = Quaternion.identity();
    final Vector3 beginScale = Vector3.zero();
    final Vector3 endScale = Vector3.zero();
    begin.decompose(beginTranslation, beginRotation, beginScale);
    end.decompose(endTranslation, endRotation, endScale);
    final Vector3 lerpTranslation = beginTranslation * (1.0 - t) + endTranslation * t;
    final Quaternion lerpRotation = (beginRotation.scaled(1.0 - t) + endRotation.scaled(t)).normalized();
    final Vector3 lerpScale = beginScale * (1.0 - t) + endScale * t;
    return Matrix4.compose(lerpTranslation, lerpRotation, lerpScale);
  }
}
