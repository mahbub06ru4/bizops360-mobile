import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../auth/controllers/auth_controller.dart';

/// One bottom-nav destination.
class NavTab {
  const NavTab({
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
  });

  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
}

/// Builds the bottom nav from `auth/me` — roles decide whether "Insights"
/// appears, the tenant's industry decides whether tab 3 is "Desk" or "CRM".
/// Mirrors the navigation matrix in the design mockup.
class ShellController extends GetxController {
  ShellController(this._auth);

  final AuthController _auth;

  final RxInt currentIndex = 0.obs;

  List<NavTab> get tabs {
    final user = _auth.user;
    final isManager = user?.isManager ?? false;
    final isTravel = user?.tenant?.isTravel ?? false;

    return [
      NavTab(
        labelKey: isManager ? Tr.navTeam : Tr.navHome,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      const NavTab(
        labelKey: Tr.navTasks,
        icon: Icons.check_box_outlined,
        selectedIcon: Icons.check_box,
      ),
      NavTab(
        labelKey: isTravel ? Tr.navDesk : Tr.navCrm,
        icon: isTravel ? Icons.travel_explore_outlined : Icons.groups_outlined,
        selectedIcon: isTravel ? Icons.travel_explore : Icons.groups,
      ),
      if (isManager)
        const NavTab(
          labelKey: Tr.navInsights,
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
        ),
      const NavTab(
        labelKey: Tr.navMore,
        icon: Icons.more_horiz,
        selectedIcon: Icons.more_horiz,
      ),
    ];
  }

  void select(int index) => currentIndex.value = index;
}
