import '../../core/error/result.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

/// In-memory expenses for UI-first development (`Env.useFakeData`).
class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository() : _items = _seed();

  List<Expense> _items;
  var _nextId = 200;

  static DateTime _ago(int d) => DateTime.now().subtract(Duration(days: d));

  static List<Expense> _seed() => [
    Expense(
      id: 'e1',
      category: ExpenseCategory.travel,
      amount: 1200,
      date: _ago(1),
      status: ExpenseStatus.pending,
      note: 'CNG to airport for client pickup.',
      hasReceipt: true,
    ),
    Expense(
      id: 'e2',
      category: ExpenseCategory.meals,
      amount: 3400,
      date: _ago(3),
      status: ExpenseStatus.approved,
      note: 'Lunch with the Bali group.',
      hasReceipt: true,
    ),
    Expense(
      id: 'e3',
      category: ExpenseCategory.office,
      amount: 850,
      date: _ago(6),
      status: ExpenseStatus.reimbursed,
      note: 'Printer paper and toner.',
    ),
    Expense(
      id: 'e4',
      category: ExpenseCategory.supplier,
      amount: 15000,
      date: _ago(10),
      status: ExpenseStatus.rejected,
      note: 'Advance to visa agent — use company account instead.',
    ),
  ];

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => value);

  @override
  Future<Result<List<Expense>>> mine() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<Expense>> submit({
    required ExpenseCategory category,
    required num amount,
    required DateTime date,
    String? note,
    bool hasReceipt = false,
  }) {
    final expense = Expense(
      id: '${_nextId++}',
      category: category,
      amount: amount,
      date: date,
      status: ExpenseStatus.pending,
      note: note,
      hasReceipt: hasReceipt,
    );
    _items = [expense, ..._items];
    return _delayed(Result.ok(expense));
  }
}
