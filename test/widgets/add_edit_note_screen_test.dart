import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/screens/add_edit_note_screen.dart';
import 'package:flutter_project/models/note.dart';
import 'package:flutter_project/services/mock_firebase_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('AddEditNoteScreen Widget Tests', () {
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

    testWidgets('AddNoteScreen hiển thị AppBar với nút back', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('EditNoteScreen hiển thị AppBar với nút check', (WidgetTester tester) async {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(createEditNoteScreen(note));

      // Check icon appears in both color picker (selected color) and AppBar
      expect(find.byIcon(Icons.check), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AddNoteScreen hiển thị 2 TextFields (title + content)', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('TextField title có hint text', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.text('Tiêu đề'), findsOneWidget);
    });

    testWidgets('TextField content có hint text', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.text('Nội dung ghi chú...'), findsOneWidget);
    });

    testWidgets('Có thể nhập text vào title field', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      // Tìm TextField đầu tiên (title)
      final titleField = find.byType(TextField).first;
      
      await tester.enterText(titleField, 'My Note Title');
      expect(find.text('My Note Title'), findsOneWidget);
    });

    testWidgets('Có thể nhập text vào content field', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      // Tìm TextField thứ hai (content)
      final contentField = find.byType(TextField).last;
      
      await tester.enterText(contentField, 'My note content here');
      expect(find.text('My note content here'), findsOneWidget);
    });

    testWidgets('EditNoteScreen hiển thị dữ liệu note có sẵn', (WidgetTester tester) async {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Existing Title',
        content: 'Existing Content',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(createEditNoteScreen(note));

      expect(find.text('Existing Title'), findsOneWidget);
      expect(find.text('Existing Content'), findsOneWidget);
    });

    testWidgets('Color picker hiển thị trong ListView', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      // Color picker là ListView horizontal
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('Nút Lưu (icon check) hiển thị trong AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      // Check icon appears in both selected color and AppBar
      expect(find.byIcon(Icons.check), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Có thể chọn màu bằng GestureDetector', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      // Color selector sử dụng GestureDetector
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Content TextField multiline', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      final contentField = tester.widget<TextField>(find.byType(TextField).last);
      
      expect(contentField.maxLines, isNull); // null means unlimited
    });

    testWidgets('Title TextField multiline enabled', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      final titleField = tester.widget<TextField>(find.byType(TextField).first);
      
      // Title field cũng có maxLines = null
      expect(titleField.maxLines, null);
    });

    testWidgets('Screen có AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar có nút back', (WidgetTester tester) async {
      await tester.pumpWidget(createAddNoteScreen());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
