import 'package:flutter_test/flutter_test.dart';

import 'package:pingme/main.dart';

void main() {
  testWidgets('PingMe app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PingMeApp());

    // Verify app title is present
    expect(find.text('PingMe'), findsWidgets);
  });
}
