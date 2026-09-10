import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../presentation/home/widgets/dashboard_section.dart';

/// Home dashboard: a glance at the visa pipeline. Counts are wired to
/// `VisaRepository` in M4 — static sample for now.
class VisaSummarySection extends StatelessWidget {
  const VisaSummarySection({super.key});

  // TODO(M4): replace with VisaRepository.pipelineSummary().
  static const _inProgress = 8;
  static const _awaitingDocs = 3;
  static const _decisionDue = 2;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: Tr.homeVisaSummary.tr,
      onViewAll: () {},
      child: Row(
        children: [
          _Stat(_inProgress, Tr.homeVisaInProgress.tr),
          const _Divider(),
          _Stat(_awaitingDocs, Tr.homeVisaAwaitingDocs.tr),
          const _Divider(),
          _Stat(_decisionDue, Tr.homeVisaDecisionDue.tr),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: text.displaySmall),
          SizedBox(height: AppSpacing.xxs),
          Text(label, style: text.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Theme.of(context).colorScheme.outline,
    );
  }
}
