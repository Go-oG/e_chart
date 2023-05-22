class GroupData {
  final String? id;
  final String? label;
  final List<SubData> data;

  GroupData(
    this.data, {
    this.id,
    this.label,
  });
}

class SubData {
  final String? label;
  final num value;
  SubData(this.value, {this.label});
}
