import 'package:flutter_test/flutter_test.dart';
import 'package:artisan_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ArtisanAiApp());
    expect(find.byType(ArtisanAiApp), findsOneWidget);
  });
}
