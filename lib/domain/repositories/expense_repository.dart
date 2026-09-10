import '../../core/error/result.dart';
import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  /// The current user's expenses, newest first.
  Future<Result<List<Expense>>> mine();

  Future<Result<Expense>> submit({
    required ExpenseCategory category,
    required num amount,
    required DateTime date,
    String? note,
    bool hasReceipt,
  });
}
