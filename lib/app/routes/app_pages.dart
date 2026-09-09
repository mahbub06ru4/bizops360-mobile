import 'package:get/get.dart';

import '../../features/auth/bindings/sign_in_binding.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/shell/bindings/shell_binding.dart';
import '../../features/shell/screens/shell_screen.dart';
import '../../features/splash/splash_binding.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';

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
    ),
    GetPage(
      name: Routes.shell,
      page: () => const ShellScreen(),
      binding: ShellBinding(),
    ),
  ];
}
