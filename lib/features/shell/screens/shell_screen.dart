import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/home_screen.dart';
import '../controllers/shell_controller.dart';

/// The signed-in container: a bottom nav assembled by [ShellController] over an
/// [IndexedStack] of feature roots. Only "Home" is built for the scaffold; the
/// rest are placeholders until their slices land.
class ShellScreen extends GetView<ShellController> {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabs = controller.tabs;
      final index = controller.currentIndex.value.clamp(0, tabs.length - 1);

      return Scaffold(
        appBar: AppBar(title: Text(tabs[index].labelKey.tr)),
        body: SafeArea(
          child: IndexedStack(
            index: index,
            children: [
              for (var i = 0; i < tabs.length; i++)
                i == 0
                    ? const HomeScreen()
                    : _Placeholder(labelKey: tabs[i].labelKey),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.select,
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.labelKey.tr,
              ),
          ],
        ),
      );
    });
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.labelKey});

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_outlined, size: 40, color: c.lineStrong),
          const SizedBox(height: 12),
          Text(labelKey.tr, style: text.titleLarge),
          const SizedBox(height: 4),
          Text(Tr.comingSoon.tr, style: text.bodyMedium),
        ],
      ),
    );
  }
}
