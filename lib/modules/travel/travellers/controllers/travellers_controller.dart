import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/traveller.dart';
import '../../../../domain/repositories/traveller_repository.dart';

class TravellersController extends GetxController {
  TravellersController(this._repo);

  final TravellerRepository _repo;

  final Rx<AsyncValue<List<Traveller>>> state =
      const AsyncValue<List<Traveller>>.loading().obs;
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.travellers()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<Traveller> get visible {
    final all = state.value.valueOrNull ?? const [];
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (t) =>
              t.name.toLowerCase().contains(q) ||
              (t.passportNumber?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}
