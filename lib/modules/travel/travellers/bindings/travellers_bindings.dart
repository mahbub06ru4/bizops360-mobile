import 'package:get/get.dart';

import '../../../../data/repositories/fake_traveller_repository.dart';
import '../../../../domain/entities/traveller.dart';
import '../../../../domain/repositories/traveller_repository.dart';
import '../controllers/traveller_detail_controller.dart';
import '../controllers/travellers_controller.dart';

// TODO(api): TravellerRepositoryImpl (industry:travel) when not useFakeData.
void _ensureRepo() {
  if (!Get.isRegistered<TravellerRepository>()) {
    Get.put<TravellerRepository>(FakeTravellerRepository(), permanent: true);
  }
}

class TravellersBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    Get.lazyPut<TravellersController>(() => TravellersController(Get.find()));
  }
}

class TravellerDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    final arg = Get.arguments;
    final seed = arg is Traveller ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<TravellerDetailController>(
      () => TravellerDetailController(Get.find(), id, seed: seed),
    );
  }
}
