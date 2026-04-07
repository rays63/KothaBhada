import 'package:flutter_test/flutter_test.dart';
import 'package:kothabhada/main.dart';

void main() {
  testWidgets('dashboard renders core rental metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Kothabhada'), findsOneWidget);
    expect(find.text('Portfolio Health'), findsOneWidget);
    expect(find.text('October 2023'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });
}
