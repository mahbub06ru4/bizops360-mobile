import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/widgets/widgets.dart';

/// Visa applications queued by stage. Travel tenants only (gated in
/// [ShellController]). Real content lands in M4.
class VisaQueueScreen extends StatelessWidget {
  const VisaQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navVisa.tr)),
      body: ComingSoon(label: Tr.navVisa.tr),
    );
  }
}
