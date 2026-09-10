import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/attendance.dart';
import '../controllers/attendance_controller.dart';
import '../hr_display.dart';

class AttendanceScreen extends GetView<AttendanceController> {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.attTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Obx(
              () => AsyncView<AttendanceToday>(
                value: controller.today.value,
                onRetry: controller.load,
                data: (t) => _PunchCard(
                  today: t,
                  busy: controller.busy.value,
                  onPunch: controller.punch,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppSectionLabel(Tr.attHistory.tr),
            SizedBox(height: AppSpacing.xs),
            Obx(
              () => AsyncView<List<AttendanceDay>>(
                value: controller.history.value,
                onRetry: controller.load,
                isEmpty: (l) => l.isEmpty,
                data: (days) => Column(
                  children: [for (final d in days) _HistoryRow(day: d)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PunchCard extends StatelessWidget {
  const _PunchCard({
    required this.today,
    required this.busy,
    required this.onPunch,
  });

  final AttendanceToday today;
  final bool busy;
  final VoidCallback onPunch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final fmt = DateFormat.jm();

    final String caption;
    if (today.isDone) {
      caption = Tr.attDone.tr;
    } else if (today.isCheckedIn) {
      caption = '${Tr.attCheckedInAt.tr} ${fmt.format(today.checkIn!)}';
    } else {
      caption = Tr.attNotIn.tr;
    }

    return AppCard(
      child: Column(
        children: [
          Text(
            DateFormat.MMMMEEEEd().format(DateTime.now()),
            style: text.bodySmall,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(caption, style: text.titleMedium, textAlign: TextAlign.center),
          if (today.checkIn != null) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Stamp(
                  label: Tr.attCheckIn.tr,
                  time: fmt.format(today.checkIn!),
                ),
                if (today.checkOut != null) ...[
                  Icon(Icons.arrow_right_alt, color: c.inkFaint),
                  _Stamp(
                    label: Tr.attCheckOut.tr,
                    time: fmt.format(today.checkOut!),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: AppSpacing.md),
          if (!today.isDone)
            AppButton(
              label: today.isCheckedIn ? Tr.attCheckOut.tr : Tr.attCheckIn.tr,
              icon: today.isCheckedIn ? Icons.logout : Icons.login,
              loading: busy,
              onPressed: onPunch,
            ),
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Text(label, style: text.bodySmall),
          Text(time, style: text.titleMedium),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final worked = day.worked;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.d().format(day.date), style: text.titleMedium),
                Text(DateFormat.E().format(day.date), style: text.bodySmall),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              worked == null
                  ? '—'
                  : '${worked.inHours}h ${worked.inMinutes % 60}m',
              style: text.bodyMedium,
            ),
          ),
          AppStatusChip(day.status.labelKey.tr, tone: day.status.tone),
        ],
      ),
    );
  }
}
