import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/can.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../modules/travel/dashboard/visa_summary_section.dart';
import '../widgets/agenda_section.dart';
import '../widgets/quick_actions_section.dart';

/// The operational travel dashboard. A greeting header over a stack of
/// permission-gated [DashboardSection]s — compose, don't grow a build method.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TODO(M3/M4): these come from the follow-up / task repositories.
  static const _followUps = [
    AgendaItem(
      'Call Rahim about Schengen quote',
      'Today',
      tone: ChipTone.brand,
    ),
    AgendaItem(
      'Send Dubai package to Nusrat',
      'Overdue',
      tone: ChipTone.critical,
    ),
  ];
  static const _tasks = [
    AgendaItem(
      'Collect passport — Karim family',
      'Today',
      tone: ChipTone.brand,
    ),
    AgendaItem('Confirm hotel — Bali group', 'Tomorrow'),
    AgendaItem('Review invoice #2043', 'Fri'),
  ];

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h < 12) return Tr.greetingMorning;
    if (h < 17) return Tr.greetingAfternoon;
    return Tr.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final text = Theme.of(context).textTheme;
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        toolbarHeight: 72,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greetingKey().tr}, $firstName',
              style: text.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (user?.tenant != null)
              Text(
                user!.tenant!.name,
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed<void>(Routes.notifications),
            icon: const AppBadge(
              count: 3,
              child: Icon(Icons.notifications_none),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Future<void>.delayed(const Duration(milliseconds: 600)),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const QuickActionsSection(),
            const Can(
              Perm.visaView,
              feature: Feature.travelVisa,
              travelOnly: true,
              child: VisaSummarySection(),
            ),
            Can(
              Perm.followUpManage,
              feature: Feature.crm,
              child: AgendaSection(
                title: Tr.homeFollowUps.tr,
                items: _followUps,
                onViewAll: () => Get.toNamed<void>(Routes.followUps),
              ),
            ),
            Can(
              Perm.taskView,
              feature: Feature.tasks,
              child: AgendaSection(
                title: Tr.homeMyTasks.tr,
                items: _tasks,
                onViewAll: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
