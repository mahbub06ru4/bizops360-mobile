import 'package:get/get.dart';

import '../../../data/repositories/fake_expense_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../controllers/expenses_controller.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    // TODO(api): ExpenseRepositoryImpl when Env.useFakeData is false.
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put<ExpenseRepository>(FakeExpenseRepository(), permanent: true);
    }
    Get.lazyPut<ExpensesController>(() => ExpensesController(Get.find()));
  }
}
