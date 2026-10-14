class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.userIds,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.status,
  });

  final String id;
  final String title;
  final List<String> userIds;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final String status;
}
