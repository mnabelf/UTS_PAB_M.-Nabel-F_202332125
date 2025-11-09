class TransactionModel {
  final String category;
  final DateTime date;
  final double amount;
  final bool isIncome;
  final String? note;

  TransactionModel({
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.note,
  });
}
