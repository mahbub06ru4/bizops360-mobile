import 'package:get/get.dart';

import '../../presentation/auth/bindings/sign_in_binding.dart';
import '../../presentation/auth/screens/sign_in_screen.dart';
import '../../presentation/common/coming_soon_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/shell/bindings/shell_binding.dart';
import '../../presentation/shell/screens/shell_screen.dart';
import '../../presentation/splash/splash_binding.dart';
import '../../presentation/splash/splash_screen.dart';
import 'app_routes.dart';
import 'route_guard.dart';

abstract final class AppPages {
  static const initial = Routes.splash;

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
    GetPage(
      name: Routes.shell,
      page: () => const ShellScreen(),
      binding: ShellBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.comingSoon,
      page: () => const ComingSoonScreen(),
      middlewares: [AuthGuard()],
    ),
  ];
}
