import 'package:equatable/equatable.dart';

enum ExpenseCategory { travel, meals, office, supplier, other }

enum ExpenseStatus { pending, approved, rejected, reimbursed }

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    this.note,
    this.hasReceipt = false,
  });

  final String id;
  final ExpenseCategory category;

  /// BDT.
  final num amount;
  final DateTime date;
  final ExpenseStatus status;
  final String? note;
  final bool hasReceipt;

  @override
  List<Object?> get props => [
    id,
    category,
    amount,
    date,
    status,
    note,
    hasReceipt,
  ];
}
