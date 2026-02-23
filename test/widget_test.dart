// Basic widget test for AI Keyboard App.

import 'package:flutter_test/flutter_test.dart';

import 'package:aikeyboardapp/main.dart';

void main() {
  testWidgets('App renders setup screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AiKeyboardApp());

    // Verify that the setup screen title is shown.
    expect(find.text('AI Keyboard'), findsWidgets);
  });
}
