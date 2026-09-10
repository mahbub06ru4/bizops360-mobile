import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/settings/settings_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_pill.dart';

/// Scaffold-stage home: greets the signed-in user, shows what their session
/// unlocks, and lets them switch language / theme and sign out. Feature decks
/// (attendance, tasks, follow-ups) land in the slices that follow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final settings = Get.find<SettingsController>();
    final user = auth.user;
    final text = Theme.of(context).textTheme;
    final c = context.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          user?.isManager == true ? Tr.myTeam.tr : Tr.myDay.tr,
          style: text.displaySmall,
        ),
        if (user?.tenant != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(user!.tenant!.name, style: text.bodyMedium),
          ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: c.brandSoft,
                    child: Text(
                      user?.initials ?? '?',
                      style: text.titleMedium?.copyWith(color: c.brandInk),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '', style: text.titleMedium),
                        Text(user?.email ?? '', style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final role in user?.roles ?? const <String>[])
                    StatusPill(role, dot: false),
                  if (user?.tenant?.industry != null)
                    StatusPill(
                      user!.tenant!.industry!,
                      tone: PillTone.info,
                      dot: false,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionLabel('Access'),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final perm in (user?.permissions ?? const <String>[]).take(
                8,
              ))
                ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.key_outlined,
                    size: 18,
                    color: c.inkFaint,
                  ),
                  title: Text(perm, style: text.bodyLarge),
                ),
              if ((user?.permissions.length ?? 0) > 8)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '+ ${user!.permissions.length - 8} more',
                    style: text.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: settings.toggleLocale,
                icon: const Icon(Icons.translate, size: 18),
                label: Obx(
                  () => Text(
                    settings.locale.value.languageCode == 'bn'
                        ? Tr.english.tr
                        : Tr.bengali.tr,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: auth.signOut,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(Tr.signOut.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
