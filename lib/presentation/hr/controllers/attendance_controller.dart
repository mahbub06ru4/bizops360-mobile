import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/repositories/attendance_repository.dart';

class AttendanceController extends GetxController {
  AttendanceController(this._repo);

  final AttendanceRepository _repo;

  final Rx<AsyncValue<AttendanceToday>> today =
      const AsyncValue<AttendanceToday>.loading().obs;
  final Rx<AsyncValue<List<AttendanceDay>>> history =
      const AsyncValue<List<AttendanceDay>>.loading().obs;
  final RxBool busy = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    today.value = const AsyncValue.loading();
    history.value = const AsyncValue.loading();
    today.value = (await _repo.today()).fold(AsyncValue.data, AsyncValue.error);
    history.value = (await _repo.history()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<void> punch() async {
    final current = today.value.valueOrNull;
    if (busy.value || current == null || current.isDone) return;
    busy.value = true;
    final result = current.isCheckedIn
        ? await _repo.checkOut()
        : await _repo.checkIn();
    busy.value = false;
    result.fold((t) => today.value = AsyncValue.data(t), (_) {});
  }
}
