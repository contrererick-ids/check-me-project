class Expense {
  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.paidBy,
    required this.amount,
    required this.date,
  });

  final String id;
  final String tripId;
  final String paidBy;
  final String title;
  final double amount;
  final DateTime date;
}
