import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_app/main.dart';

void main() {
  testWidgets('App smoke test - landing page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KineticApp());
    // Verify the landing page renders with the app title
    expect(find.textContaining('KINETIC'), findsWidgets);
  });
}
