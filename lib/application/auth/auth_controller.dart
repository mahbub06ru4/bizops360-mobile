import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/routing/app_routes.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth/load_session_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';

/// Holds the session for the whole app. Registered permanently in [AppBinding];
/// every gated screen, the shell and `PermissionsController` read [user] here.
class AuthController extends GetxController {
  AuthController({
    required LoadSessionUseCase loadSession,
    required SignOutUseCase signOut,
  }) : _loadSession = loadSession,
       _signOut = signOut;

  final LoadSessionUseCase _loadSession;
  final SignOutUseCase _signOut;

  final Rxn<AuthUser> _user = Rxn<AuthUser>();
  AuthUser? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  bool _handlingUnauthorized = false;

  /// Called from the splash screen. Returns the route to land on.
  Future<String> resolveStartRoute() async {
    final result = await _loadSession();
    return result.fold((u) {
      _user.value = u;
      return Routes.shell;
    }, (_) => Routes.signIn);
  }

  void setUser(AuthUser user) => _user.value = user;

  Future<void> signOut() async {
    await _signOut();
    _user.value = null;
    await Get.offAllNamed<void>(Routes.signIn);
  }

  /// Invoked once by the auth interceptor when the server rejects the token.
  Future<void> onUnauthorized() async {
    if (_handlingUnauthorized || !isAuthenticated) return;
    _handlingUnauthorized = true;
    _user.value = null;
    await Get.offAllNamed<void>(Routes.signIn);
    Get.snackbar(
      Tr.appName.tr,
      Tr.sessionEnded.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    _handlingUnauthorized = false;
  }
}
