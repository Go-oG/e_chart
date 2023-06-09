import 'package:e_chart/src/utils/uuid_util.dart';

import 'dynamic_text.dart';

class GroupData {
  late final String id;
  DynamicText? label;
  List<ItemData> childData;

  GroupData(
    this.childData, {
    String? id,
    this.label,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is GroupData && other.id == id;
  }
}

class ItemData {
  late final String id;
  num value;
  DynamicText? label;

  ItemData({this.value = 0, this.label, String? id}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is ItemData && other.id == id;
  }
}
