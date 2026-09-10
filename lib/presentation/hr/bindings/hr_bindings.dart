import 'package:get/get.dart';

import '../../../data/datasources/finance_remote_datasource.dart';
import '../../../data/datasources/hr_remote_datasource.dart';
import '../../../data/repositories/attendance_repository_impl.dart';
import '../../../data/repositories/expense_repository_impl.dart';
import '../../../data/repositories/fake_attendance_repository.dart';
import '../../../data/repositories/fake_expense_repository.dart';
import '../../../data/repositories/fake_leave_repository.dart';
import '../../../data/repositories/leave_repository_impl.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/leave_repository.dart';
import '../../expenses/controllers/expense_approvals_controller.dart';
import '../controllers/approvals_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/leave_controller.dart';

void _ensureAttendanceRepo() => registerRepo<AttendanceRepository>(
  (client) => AttendanceRepositoryImpl(HrRemoteDataSource(client)),
  FakeAttendanceRepository.new,
);

void _ensureLeaveRepo() => registerRepo<LeaveRepository>(
  (client) => LeaveRepositoryImpl(HrRemoteDataSource(client)),
  FakeLeaveRepository.new,
);

void ensureExpenseRepo() => registerRepo<ExpenseRepository>(
  (client) => ExpenseRepositoryImpl(FinanceRemoteDataSource(client)),
  FakeExpenseRepository.new,
);

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    _ensureAttendanceRepo();
    Get.lazyPut<AttendanceController>(() => AttendanceController(Get.find()));
  }
}

class LeaveBinding extends Bindings {
  @override
  void dependencies() {
    _ensureLeaveRepo();
    Get.lazyPut<LeaveController>(() => LeaveController(Get.find()));
  }
}

class ApprovalsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureLeaveRepo();
    ensureExpenseRepo();
    Get.lazyPut<ApprovalsController>(() => ApprovalsController(Get.find()));
    Get.lazyPut<ExpenseApprovalsController>(
      () => ExpenseApprovalsController(Get.find()),
    );
  }
}
