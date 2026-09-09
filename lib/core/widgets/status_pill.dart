import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum PillTone { brand, signal, critical, info, neutral }

/// Compact status chip. State reads at a glance from tone + an optional dot,
/// per the design mockup (visa stages, booking status, "due"/"late").
class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    this.tone = PillTone.neutral,
    this.dot = true,
    super.key,
  });

  final String label;
  final PillTone tone;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ({Color bg, Color fg}) palette = switch (tone) {
      PillTone.brand => (bg: c.brandSoft, fg: c.brandInk),
      PillTone.signal => (bg: c.signalSoft, fg: c.signalInk),
      PillTone.critical => (bg: c.criticalSoft, fg: c.criticalInk),
      PillTone.info => (bg: c.infoSoft, fg: c.infoInk),
      PillTone.neutral => (bg: c.surfaceAlt, fg: c.inkMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(999),
        border: tone == PillTone.neutral ? Border.all(color: c.line) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: palette.fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: palette.fg,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
