import 'package:get/get.dart';

import '../../../data/repositories/fake_task_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import '../controllers/tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    // TODO(api): TaskRepositoryImpl when Env.useFakeData is false.
    if (!Get.isRegistered<TaskRepository>()) {
      Get.put<TaskRepository>(FakeTaskRepository(), permanent: true);
    }
    Get.lazyPut<TasksController>(() => TasksController(Get.find()));
  }
}
