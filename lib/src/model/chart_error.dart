class ChartError extends Error{
  final String message;

  ChartError(this.message);

  @override
  String toString() {
    return message;
  }
}