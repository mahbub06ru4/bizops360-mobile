import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'application/app_binding.dart';
import 'core/config/env.dart';
import 'core/config/flavor.dart';
import 'core/observability/crash_reporter.dart';
import 'core/storage/kv_store.dart';

/// Shared startup for every flavor entrypoint: pin the flavor, warm the local
/// KV box, wire the object graph, install crash handlers, then run the app —
/// all inside a guarded zone so async errors are captured too.
Future<void> bootstrap(FlavorConfig config) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Env.init(config);
      installCrashHandlers();
      await KvStore.ensureInitialised();
      AppBinding().dependencies();
      runApp(const BizOpsApp());
    },
    (error, stack) =>
        CrashReporter.instance.recordError(error, stack, fatal: true),
  );
}
