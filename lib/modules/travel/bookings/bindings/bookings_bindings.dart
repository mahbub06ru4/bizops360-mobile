import 'package:get/get.dart';

import '../../../../data/repositories/fake_booking_repository.dart';
import '../../../../domain/entities/booking.dart';
import '../../../../domain/repositories/booking_repository.dart';
import '../controllers/booking_detail_controller.dart';
import '../controllers/bookings_controller.dart';
import '../controllers/departures_controller.dart';

// TODO(api): BookingRepositoryImpl (industry:travel) when not useFakeData.
void _ensureRepo() {
  if (!Get.isRegistered<BookingRepository>()) {
    Get.put<BookingRepository>(FakeBookingRepository(), permanent: true);
  }
}

class BookingsBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    Get.lazyPut<BookingsController>(() => BookingsController(Get.find()));
  }
}

class BookingDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    final arg = Get.arguments;
    final seed = arg is Booking ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<BookingDetailController>(
      () => BookingDetailController(Get.find(), id, seed: seed),
    );
  }
}

class DeparturesBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    Get.lazyPut<DeparturesController>(() => DeparturesController(Get.find()));
  }
}
