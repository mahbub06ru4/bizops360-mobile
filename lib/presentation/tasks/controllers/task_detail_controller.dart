import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/task_item.dart';
import '../../../domain/repositories/task_repository.dart';

class TaskDetailController extends GetxController {
  TaskDetailController(this._repo, this._taskId, {TaskItem? seed})
    : state = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final TaskRepository _repo;
  final String _taskId;

  final Rx<AsyncValue<TaskItem>> state;
  final RxBool updating = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (state.value is! AsyncData) reload();
  }

  Future<void> reload() async {
    state.value = (await _repo.byId(
      _taskId,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> setStatus(TaskStatus status) async {
    updating.value = true;
    final result = await _repo.updateStatus(_taskId, status);
    updating.value = false;
    result.fold((t) => state.value = AsyncValue.data(t), (_) {});
  }

  void toggleDone() {
    final task = state.value.valueOrNull;
    if (task == null) return;
    setStatus(task.isDone ? TaskStatus.open : TaskStatus.done);
  }
}
