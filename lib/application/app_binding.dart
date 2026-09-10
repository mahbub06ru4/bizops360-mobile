import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/storage/kv_store.dart';
import '../core/storage/secure_store.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth/auth_controller.dart';
import 'settings/settings_controller.dart';

/// Wires the object graph once, before the first route. Order matters: storage →
/// interceptor → client → data source → repository → session controller. The
/// interceptor's unauthorized hook resolves [AuthController] lazily to avoid a
/// cycle.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<KvStore>(KvStore(), permanent: true);
    Get.put<SecureStore>(SecureStore(), permanent: true);
    Get.put<SettingsController>(
      SettingsController(Get.find()),
      permanent: true,
    );

    final authInterceptor = AuthInterceptor(
      secureStore: Get.find<SecureStore>(),
      onUnauthorized: () => Get.find<AuthController>().onUnauthorized(),
    );

    Get.put<ApiClient>(
      ApiClient.configured(authInterceptor: authInterceptor),
      permanent: true,
    );
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSource(Get.find()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(remote: Get.find(), secureStore: Get.find()),
      permanent: true,
    );
    Get.put<AuthController>(AuthController(Get.find()), permanent: true);
  }
}
