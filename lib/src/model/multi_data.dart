import 'dynamic_data.dart';
import 'dynamic_text.dart';

///多功能-数据描述
class MultiData {
  final DynamicData x;
  final DynamicData y;
  final DynamicText? label;

  const MultiData(this.x, this.y, {this.label});
}
