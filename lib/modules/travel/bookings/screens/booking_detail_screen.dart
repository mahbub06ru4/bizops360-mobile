import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/booking.dart';
import '../booking_display.dart';
import '../controllers/booking_detail_controller.dart';

class BookingDetailScreen extends GetView<BookingDetailController> {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.state.value.valueOrNull?.reference ??
                Tr.bookingsTitle.tr,
          ),
        ),
      ),
      body: Obx(
        () => AsyncView<Booking>(
          value: controller.state.value,
          onRetry: controller.reload,
          data: (b) => _body(context, b),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final b = controller.state.value.valueOrNull;
        if (b == null || !b.isActive) return const SizedBox.shrink();
        return SafeArea(
          minimum: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: Tr.bkCancel.tr,
                  variant: AppButtonVariant.secondary,
                  loading: controller.busy.value,
                  onPressed: controller.cancel,
                ),
              ),
              if (b.status == BookingStatus.held) ...[
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: Tr.bkIssue.tr,
                    loading: controller.busy.value,
                    onPressed: controller.issue,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _body(BuildContext context, Booking b) {
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
        Row(
          children: [
            Icon(b.kind.icon, color: c.inkMuted),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${b.kind.labelKey.tr} · ${b.travellerName}',
                style: text.titleMedium,
              ),
            ),
            AppStatusChip(b.status.labelKey.tr, tone: b.status.tone),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: [
              _kv(context, Tr.bkRef.tr, b.reference, mono: true),
              _kv(
                context,
                Tr.bkDate.tr,
                DateFormat.yMMMEd().format(b.travelDate),
              ),
              _kv(context, Tr.bkAmount.tr, b.amount.toBdt()),
            ],
          ),
        ),
        if (b.segments.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.bkSegments.tr),
          for (final s in b.segments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flight_takeoff),
              title: Text(
                '${s.from} → ${s.to}',
                style: AppTypography.mono(c.ink, size: 14),
              ),
              subtitle: Text('${s.carrier} ${s.flightNo}'),
              trailing: Text(
                DateFormat.MMMd().add_jm().format(s.departsAt),
                style: text.bodySmall,
              ),
            ),
        ],
        if (b.hotelName != null) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.bkHotel.tr),
          SizedBox(height: AppSpacing.xs),
          Text(b.hotelName!, style: text.bodyLarge),
        ],
        if (b.itinerary != null) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.bkItinerary.tr),
          SizedBox(height: AppSpacing.xs),
          Text(b.itinerary!, style: text.bodyLarge),
        ],
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v, {bool mono = false}) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(k, style: text.bodyMedium)),
          Text(
            v,
            style: mono
                ? AppTypography.mono(context.colors.ink)
                : text.titleMedium,
          ),
        ],
      ),
    );
  }
}
