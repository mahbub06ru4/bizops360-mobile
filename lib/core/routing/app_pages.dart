import 'package:get/get.dart';

import '../../presentation/auth/bindings/sign_in_binding.dart';
import '../../presentation/auth/screens/sign_in_screen.dart';
import '../../presentation/common/coming_soon_screen.dart';
import '../../presentation/crm/bindings/crm_bindings.dart';
import '../../presentation/crm/screens/customer_detail_screen.dart';
import '../../presentation/crm/screens/follow_ups_screen.dart';
import '../../presentation/expenses/bindings/expenses_binding.dart';
import '../../presentation/expenses/screens/expense_new_screen.dart';
import '../../presentation/expenses/screens/expenses_screen.dart';
import '../../presentation/hr/bindings/hr_bindings.dart';
import '../../presentation/hr/screens/approvals_screen.dart';
import '../../presentation/hr/screens/attendance_screen.dart';
import '../../presentation/hr/screens/leave_request_screen.dart';
import '../../presentation/hr/screens/leave_screen.dart';
import '../../presentation/notifications/bindings/notifications_binding.dart';
import '../../presentation/notifications/screens/notifications_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/shell/bindings/shell_binding.dart';
import '../../presentation/shell/screens/shell_screen.dart';
import '../../presentation/splash/splash_binding.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/tasks/bindings/task_detail_binding.dart';
import '../../presentation/tasks/screens/task_detail_screen.dart';
import 'app_routes.dart';
import 'route_guard.dart';

abstract final class AppPages {
  static const initial = Routes.splash;

  static GetPage<dynamic> _guarded(
    String name,
    GetPageBuilder page, {
    Bindings? binding,
  }) => GetPage(
    name: name,
    page: page,
    binding: binding,
    middlewares: [AuthGuard()],
  );

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.signIn,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
      middlewares: [AuthGuard()],
    ),
    _guarded(Routes.shell, () => const ShellScreen(), binding: ShellBinding()),
    _guarded(
      Routes.notifications,
      () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    _guarded(
      Routes.taskDetail,
      () => const TaskDetailScreen(),
      binding: TaskDetailBinding(),
    ),
    _guarded(
      Routes.attendance,
      () => const AttendanceScreen(),
      binding: AttendanceBinding(),
    ),
    _guarded(Routes.leave, () => const LeaveScreen(), binding: LeaveBinding()),
    // No binding — reuses the LeaveController from the LeaveScreen beneath it.
    _guarded(Routes.leaveRequest, () => const LeaveRequestScreen()),
    _guarded(
      Routes.approvals,
      () => const ApprovalsScreen(),
      binding: ApprovalsBinding(),
    ),
    _guarded(
      Routes.customerDetail,
      () => const CustomerDetailScreen(),
      binding: CustomerDetailBinding(),
    ),
    _guarded(
      Routes.followUps,
      () => const FollowUpsScreen(),
      binding: FollowUpsBinding(),
    ),
    _guarded(
      Routes.expenses,
      () => const ExpensesScreen(),
      binding: ExpensesBinding(),
    ),
    // No binding — reuses the ExpensesController from the ExpensesScreen beneath.
    _guarded(Routes.expenseNew, () => const ExpenseNewScreen()),
    _guarded(Routes.settings, () => const SettingsScreen()),
    _guarded(Routes.profile, () => const ProfileScreen()),
    _guarded(Routes.comingSoon, () => const ComingSoonScreen()),
  ];
}
