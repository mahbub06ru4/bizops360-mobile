import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../application/settings/settings_controller.dart';
import '../core/localization/app_translations.dart';
import '../core/localization/translation_keys.dart';
import '../core/routing/app_pages.dart';
import '../core/theme/app_theme.dart';

class BizOpsApp extends StatelessWidget {
  const BizOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: Tr.appName.tr,
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode.value,
        translations: AppTranslations(),
        locale: settings.locale.value,
        fallbackLocale: AppTranslations.fallback,
        supportedLocales: const [
          AppTranslations.english,
          AppTranslations.bengali,
        ],
      ),
    );
  }
}
