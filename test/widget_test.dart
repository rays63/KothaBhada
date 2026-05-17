import 'package:flutter_test/flutter_test.dart';
import 'package:kothabhada/main.dart';
import 'package:kothabhada/services/rental_repository.dart';

void main() {
  testWidgets('dashboard renders core rental metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(repository: InMemoryRentalRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Kothabhada'), findsOneWidget);
    expect(find.text('Portfolio Health'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
