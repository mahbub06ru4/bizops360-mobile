import 'package:get/get.dart';

import '../../../data/repositories/fake_task_repository.dart';
import '../../../domain/entities/task_item.dart';
import '../../../domain/repositories/task_repository.dart';
import '../controllers/task_detail_controller.dart';

class TaskDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TaskRepository>()) {
      Get.put<TaskRepository>(FakeTaskRepository(), permanent: true);
    }
    final arg = Get.arguments;
    final seed = arg is TaskItem ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<TaskDetailController>(
      () => TaskDetailController(Get.find(), id, seed: seed),
    );
  }
}
