import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_info/main.dart';

void main() {
  testWidgets('NusaInfoApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NusaInfoApp());

    // Verify that the title is rendered
    expect(find.text('NusaInfo - Pengumuman'), findsOneWidget);
  });
}
