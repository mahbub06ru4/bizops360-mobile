import 'package:get/get.dart';

import '../../../../data/datasources/booking_remote_datasource.dart';
import '../../../../data/repositories/booking_repository_impl.dart';
import '../../../../data/repositories/fake_booking_repository.dart';
import '../../../../data/repositories/repo_registry.dart';
import '../../../../domain/entities/booking.dart';
import '../../../../domain/repositories/booking_repository.dart';
import '../controllers/booking_detail_controller.dart';
import '../controllers/bookings_controller.dart';
import '../controllers/departures_controller.dart';

void _ensureRepo() => registerRepo<BookingRepository>(
  (client) => BookingRepositoryImpl(BookingRemoteDataSource(client)),
  FakeBookingRepository.new,
);

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
