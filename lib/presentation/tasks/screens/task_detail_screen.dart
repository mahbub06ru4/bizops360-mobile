import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/task_item.dart';
import '../controllers/task_detail_controller.dart';
import '../task_display.dart';

class TaskDetailScreen extends GetView<TaskDetailController> {
  const TaskDetailScreen({super.key});

  // TODO(api): subtasks + comments come from the task detail payload.
  static const _subtasks = [
    (label: 'Passport — father', done: true),
    (label: 'Passport — mother', done: true),
    (label: 'Passport — son', done: false),
    (label: 'Passport — daughter', done: false),
  ];
  static const _comments = [
    (author: 'Nadia', when: '2h', body: 'Father and mother collected today.'),
    (author: 'You', when: '1h', body: 'Chasing the kids\' passports tomorrow.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navTasks.tr)),
      body: Obx(
        () => AsyncView<TaskItem>(
          value: controller.state.value,
          onRetry: controller.reload,
          data: _body,
        ),
      ),
      bottomNavigationBar: Obx(() {
        final task = controller.state.value.valueOrNull;
        if (task == null) return const SizedBox.shrink();
        return SafeArea(
          minimum: EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: task.isDone ? Tr.taskReopen.tr : Tr.taskMarkDone.tr,
            loading: controller.updating.value,
            icon: task.isDone ? Icons.undo : Icons.check,
            onPressed: controller.toggleDone,
          ),
        );
      }),
    );
  }

  Widget _body(TaskItem task) {
    return Builder(
      builder: (context) {
        final c = context.colors;
        final text = Theme.of(context).textTheme;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(task.title, style: text.headlineSmall),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AppStatusChip(task.status.labelKey.tr, tone: task.status.tone),
                AppStatusChip(
                  task.priority.labelKey.tr,
                  tone: task.priority.tone,
                  dot: false,
                ),
                if (task.dueDate != null)
                  AppStatusChip(
                    '${Tr.taskDue.tr}: ${DateFormat.MMMd().format(task.dueDate!)}',
                    tone: task.isOverdue ? ChipTone.critical : ChipTone.neutral,
                    dot: false,
                  ),
              ],
            ),
            if (task.description != null) ...[
              SizedBox(height: AppSpacing.lg),
              Text(task.description!, style: text.bodyLarge),
            ],
            SizedBox(height: AppSpacing.xl),
            AppSectionLabel(
              '${Tr.taskSubtasks.tr} · ${_subtasks.where((s) => s.done).length}/${_subtasks.length}',
            ),
            SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: _subtasks.where((s) => s.done).length / _subtasks.length,
              borderRadius: AppRadius.brPill,
              minHeight: 6,
              backgroundColor: c.surfaceAlt,
            ),
            SizedBox(height: AppSpacing.sm),
            for (final s in _subtasks)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: s.done,
                onChanged: (_) {},
                title: Text(s.label),
              ),
            SizedBox(height: AppSpacing.xl),
            AppSectionLabel('${Tr.taskComments.tr} · ${_comments.length}'),
            SizedBox(height: AppSpacing.xs),
            for (final m in _comments)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(name: m.author, size: 32),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.author} · ${m.when}',
                            style: text.bodySmall,
                          ),
                          Text(m.body, style: text.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            AppTextField(
              label: Tr.taskAddComment.tr,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send_outlined, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }
}
