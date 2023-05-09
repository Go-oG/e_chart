class DateRange {
  final DateTime startDate;

  final DateTime endDate;

  DateRange(this.startDate, this.endDate);

  DateRange.now():this(DateTime.now(),DateTime.now());

  @override
  int get hashCode {
    String s1 = '${startDate.year}${startDate.month}${startDate.day}';
    String s2 = '${endDate.year}${endDate.month}${endDate.day}';

    return s1.hashCode & s2.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is DateRange) {
      String s1 = '${startDate.year}${startDate.month}${startDate.day}';
      String s2 = '${endDate.year}${endDate.month}${endDate.day}';

      String s3 = '${other.startDate.year}${other.startDate.month}${other.startDate.day}';
      String s4 = '${other.endDate.year}${other.endDate.month}${other.endDate.day}';

      return s1 == s3 && s2 == s4;
    }

    return false;
  }
}
