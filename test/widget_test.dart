import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('Text widget hiển thị đúng', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hello Flutter'),
          ),
        ),
      );

      expect(find.text('Hello Flutter'), findsOneWidget);
    });

    testWidgets('Button có thể tap', (WidgetTester tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => counter++,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(counter, 1);
    });

    testWidgets('TextField nhận input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test input');
      expect(controller.text, 'Test input');
    });
  });
}
