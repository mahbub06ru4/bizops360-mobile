import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/leave_request.dart';
import '../controllers/approvals_controller.dart';
import '../hr_display.dart';

class ApprovalsScreen extends GetView<ApprovalsController> {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.approvalsTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<LeaveRequest>>(
            value: controller.pending.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: AppEmptyState(message: Tr.approvalsEmpty.tr),
            data: (list) => ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final r in list)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ApprovalCard(
                      request: r,
                      busy: controller.actingOn.value == r.id,
                      onDecide: (approve) =>
                          controller.decide(r.id, approve: approve),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.request,
    required this.busy,
    required this.onDecide,
  });

  final LeaveRequest request;
  final bool busy;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final range =
        '${DateFormat.MMMd().format(request.from)} – ${DateFormat.MMMd().format(request.to)}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: request.requesterName ?? '?', size: 32),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  request.requesterName ?? '',
                  style: text.titleMedium,
                ),
              ),
              AppStatusChip(
                '${request.type.labelKey.tr} · ${Tr.leaveDaysN.trParams({'n': '${request.days}'})}',
                dot: false,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(range, style: text.bodySmall),
          SizedBox(height: AppSpacing.xxs),
          Text(request.reason, style: text.bodyMedium),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: Tr.reject.tr,
                  variant: AppButtonVariant.secondary,
                  loading: busy,
                  onPressed: () => onDecide(false),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: Tr.approve.tr,
                  loading: busy,
                  onPressed: () => onDecide(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
