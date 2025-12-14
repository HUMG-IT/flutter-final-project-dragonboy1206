import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/screens/add_edit_note_screen.dart';
import 'package:flutter_project/models/note.dart';
import 'package:flutter_project/services/mock_firebase_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('AddEditNoteScreen - UI Tests quan trọng', () {
    late MockFirebaseService noteService;

    setUp(() {
      noteService = MockFirebaseService();
    });

    Widget createAddNoteScreen() {
      return ChangeNotifierProvider.value(
        value: noteService,
        child: const MaterialApp(
          home: AddEditNoteScreen(),
        ),
      );
    }

    Widget createEditNoteScreen(Note note) {
      return ChangeNotifierProvider.value(
        value: noteService,
        child: MaterialApp(
          home: AddEditNoteScreen(note: note),
        ),
      );
    }

    testWidgets('AddNoteScreen hiển thị AppBar và TextFields', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // title và content
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.check), findsWidgets); // Save button
    });

    testWidgets('Có thể nhập text vào title và content', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      // Nhập title
      await tester.enterText(find.byType(TextField).first, 'Test Title');
      expect(find.text('Test Title'), findsOneWidget);

      // Nhập content
      await tester.enterText(find.byType(TextField).last, 'Test Content');
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('EditNoteScreen hiển thị dữ liệu note có sẵn', (WidgetTester tester) async {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Existing Note',
        content: 'Existing Content',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(createEditNoteScreen(note));

      expect(find.text('Existing Note'), findsOneWidget);
      expect(find.text('Existing Content'), findsOneWidget);
    });

    testWidgets('Color picker hiển thị', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.byType(ListView), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets); // Color buttons
    });
  });
}
