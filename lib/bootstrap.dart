import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'application/app_binding.dart';
import 'core/config/env.dart';
import 'core/config/flavor.dart';
import 'core/storage/kv_store.dart';

/// Shared startup for every flavor entrypoint: pin the flavor, warm the local
/// KV box, wire the object graph, then run the app.
Future<void> bootstrap(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(config);
  await KvStore.ensureInitialised();
  AppBinding().dependencies();
  runApp(const BizOpsApp());
}
