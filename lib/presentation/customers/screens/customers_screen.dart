import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/widgets/widgets.dart';

/// Customers / CRM list. Real content lands in M3 (common CRM) and M4 (travel
/// customers & passengers).
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navCustomers.tr)),
      body: ComingSoon(label: Tr.navCustomers.tr),
    );
  }
}
