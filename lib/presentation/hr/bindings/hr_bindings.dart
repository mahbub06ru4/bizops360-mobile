import 'package:get/get.dart';

import '../../../data/repositories/fake_attendance_repository.dart';
import '../../../data/repositories/fake_expense_repository.dart';
import '../../../data/repositories/fake_leave_repository.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/leave_repository.dart';
import '../../expenses/controllers/expense_approvals_controller.dart';
import '../controllers/approvals_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/leave_controller.dart';

// TODO(api): swap the fakes for HTTP-backed impls when Env.useFakeData is false.

void _ensureAttendanceRepo() {
  if (!Get.isRegistered<AttendanceRepository>()) {
    Get.put<AttendanceRepository>(FakeAttendanceRepository(), permanent: true);
  }
}

void _ensureLeaveRepo() {
  if (!Get.isRegistered<LeaveRepository>()) {
    Get.put<LeaveRepository>(FakeLeaveRepository(), permanent: true);
  }
}

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
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put<ExpenseRepository>(FakeExpenseRepository(), permanent: true);
    }
    Get.lazyPut<ApprovalsController>(() => ApprovalsController(Get.find()));
    Get.lazyPut<ExpenseApprovalsController>(
      () => ExpenseApprovalsController(Get.find()),
    );
  }
}
