import '../index.dart';
import '../render/render_adapter.dart';

final class AttachInfo {
  RenderAdapter root;

  AttachInfo(this.root);

  ChartView? viewRequestingLayout;
}
