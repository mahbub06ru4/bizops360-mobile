import 'package:get/get.dart';

import '../../../application/navigation/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController(Get.find()));
  }
}
