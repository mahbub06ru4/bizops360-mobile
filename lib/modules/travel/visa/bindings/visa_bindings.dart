import 'package:get/get.dart';

import '../../../../data/repositories/fake_visa_repository.dart';
import '../../../../domain/entities/visa_application.dart';
import '../../../../domain/repositories/visa_repository.dart';
import '../controllers/visa_detail_controller.dart';
import '../controllers/visa_queue_controller.dart';

// TODO(api): VisaRepositoryImpl (industry:travel routes) when not useFakeData.
void _ensureVisaRepo() {
  if (!Get.isRegistered<VisaRepository>()) {
    Get.put<VisaRepository>(FakeVisaRepository(), permanent: true);
  }
}

class VisaQueueBinding extends Bindings {
  @override
  void dependencies() {
    _ensureVisaRepo();
    Get.lazyPut<VisaQueueController>(() => VisaQueueController(Get.find()));
  }
}

class VisaDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureVisaRepo();
    final arg = Get.arguments;
    final seed = arg is VisaApplication ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<VisaDetailController>(
      () => VisaDetailController(Get.find(), id, seed: seed),
    );
  }
}
