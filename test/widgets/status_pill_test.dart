import 'package:bizops360_mobile/core/theme/app_theme.dart';
import 'package:bizops360_mobile/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders its label', (tester) async {
    await tester.pumpWidget(
      host(const StatusPill('Ticketed', tone: PillTone.brand)),
    );
    expect(find.text('Ticketed'), findsOneWidget);
  });

  testWidgets('renders in dark theme without throwing', (tester) async {
    await tester.pumpWidget(
      host(
        const StatusPill('Docs pending', tone: PillTone.signal),
        brightness: Brightness.dark,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Docs pending'), findsOneWidget);
  });
}
