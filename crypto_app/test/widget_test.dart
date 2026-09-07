import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/main.dart';

void main() {
  testWidgets('CryptoScope app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CryptoScopeApp());
    expect(find.text('CryptoScope'), findsOneWidget);
  });
}
