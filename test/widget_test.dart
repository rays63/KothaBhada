import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kothabhada/widgets/kit/kit.dart';

void main() {
  testWidgets('StatusChip renders its label with the themed palette',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: StatusChip(label: 'Paid', kind: StatusKind.paid),
          ),
        ),
      ),
    );

    expect(find.text('Paid'), findsOneWidget);
  });

  testWidgets('AppButton invokes its callback when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: AppButton.primary(
              label: 'Add house',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add house'));
    expect(tapped, isTrue);
  });
}
