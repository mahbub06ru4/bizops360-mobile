import 'package:get/get.dart';

import '../../../data/repositories/fake_document_repository.dart';
import '../../../domain/repositories/document_repository.dart';
import '../controllers/documents_controller.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO(api): DocumentRepositoryImpl (signed URLs) when not useFakeData.
    if (!Get.isRegistered<DocumentRepository>()) {
      Get.put<DocumentRepository>(FakeDocumentRepository(), permanent: true);
    }
    Get.lazyPut<DocumentsController>(() => DocumentsController(Get.find()));
  }
}
