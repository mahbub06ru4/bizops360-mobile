import 'package:get/get.dart';

import '../../../data/repositories/fake_crm_repository.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/crm_repository.dart';
import '../controllers/customer_detail_controller.dart';
import '../controllers/customers_controller.dart';
import '../controllers/follow_ups_controller.dart';

// TODO(api): CrmRepositoryImpl when Env.useFakeData is false.
void _ensureCrmRepo() {
  if (!Get.isRegistered<CrmRepository>()) {
    Get.put<CrmRepository>(FakeCrmRepository(), permanent: true);
  }
}

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCrmRepo();
    Get.lazyPut<CustomersController>(() => CustomersController(Get.find()));
  }
}

class CustomerDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCrmRepo();
    final arg = Get.arguments;
    final seed = arg is Customer ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<CustomerDetailController>(
      () => CustomerDetailController(Get.find(), id, seed: seed),
    );
  }
}

class FollowUpsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureCrmRepo();
    Get.lazyPut<FollowUpsController>(() => FollowUpsController(Get.find()));
  }
}
