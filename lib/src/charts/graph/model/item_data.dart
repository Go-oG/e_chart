import '../../../model/data.dart';

class GraphItemData extends BaseItemData {
  ///固定的位置
  double? fx;
  double? fy;

  ///权重值
  double weight = 1;

  ///组id?
  String? groupId;

  num? width;

  num? height;

  GraphItemData({
    this.fx,
    this.fy,
    this.weight = 1,
    super.id,
    super.name,
    this.groupId,
  });
}
