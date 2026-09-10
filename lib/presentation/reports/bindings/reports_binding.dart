import 'package:get/get.dart';

import '../../../data/repositories/fake_report_repository.dart';
import '../../../domain/repositories/report_repository.dart';
import '../controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO(api): ReportRepositoryImpl (reports/* endpoints) when not useFakeData.
    if (!Get.isRegistered<ReportRepository>()) {
      Get.put<ReportRepository>(FakeReportRepository(), permanent: true);
    }
    Get.lazyPut<ReportsController>(() => ReportsController(Get.find()));
  }
}
