import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A plain surface card matching the mockup — 12px radius, hairline border,
/// no shadow. Not everything is a card; use it for a genuine grouping.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? c.line),
      ),
      child: child,
    );
  }
}

/// Uppercase tracked mini-label used above lists ("FOLLOW-UPS", "TODAY").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.trailing, super.key});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: style)),
          if (trailing != null) Text(trailing!, style: style),
        ],
      ),
    );
  }
}
