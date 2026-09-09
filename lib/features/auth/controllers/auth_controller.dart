import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../domain/entities/auth_user.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Holds the session for the whole app. Registered permanently in the initial
/// binding; every gated screen and the shell read [user] from here.
class AuthController extends GetxController {
  AuthController(this._repo);

  final AuthRepository _repo;

  final Rxn<AuthUser> _user = Rxn<AuthUser>();
  AuthUser? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  bool _handlingUnauthorized = false;

  /// Called from the splash screen. Returns the route to land on.
  Future<String> resolveStartRoute() async {
    if (!await _repo.hasStoredSession()) return Routes.signIn;

    final result = await _repo.currentUser();
    return result.fold((u) {
      _user.value = u;
      return Routes.shell;
    }, (_) => Routes.signIn);
  }

  void setUser(AuthUser user) => _user.value = user;

  Future<void> signOut() async {
    await _repo.signOut();
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
