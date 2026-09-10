import 'package:get/get.dart';

import '../../../data/repositories/fake_notification_repository.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO(api): swap for NotificationRemoteDataSource-backed impl when
    // Env.useFakeData is false — see AppBinding._wireAuthRepository for the
    // pattern. Until then the fake serves both modes.
    if (!Get.isRegistered<NotificationRepository>()) {
      Get.put<NotificationRepository>(
        FakeNotificationRepository(),
        permanent: true,
      );
    }
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find()),
    );
  }
}
