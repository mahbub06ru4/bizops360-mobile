import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/widgets/widgets.dart';

/// My tasks (Today / Overdue / Upcoming). Real content lands in M2 → Tasks.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navTasks.tr)),
      body: ComingSoon(label: Tr.navTasks.tr),
    );
  }
}
