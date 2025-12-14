import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/models/note.dart';

void main() {
  group('Note Model Unit Tests', () {
    test('Note khởi tạo với các giá trị mặc định', () {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test Content');
      expect(note.color, 'blue');
      expect(note.isPinned, false);
      expect(note.createdAt, isA<DateTime>());
      expect(note.updatedAt, isA<DateTime>());
    });

    test('Note khởi tạo với các giá trị tùy chỉnh', () {
      final createdAt = DateTime(2025, 1, 1);
      final updatedAt = DateTime(2025, 1, 2);
      
      final note = Note(
        id: '2',
        title: 'Pinned Note',
        content: 'Important Content',
        color: 'red',
        isPinned: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(note.id, '2');
      expect(note.title, 'Pinned Note');
      expect(note.content, 'Important Content');
      expect(note.color, 'red');
      expect(note.isPinned, true);
      expect(note.createdAt, createdAt);
      expect(note.updatedAt, updatedAt);
    });

    test('Note.toMap() chuyển đổi đúng sang Map', () {
      final now = DateTime.now();
      final note = Note(
        id: '3',
        title: 'Test',
        content: 'Content',
        color: 'green',
        isPinned: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = note.toMap();

      expect(map['title'], 'Test');
      expect(map['content'], 'Content');
      expect(map['color'], 'green');
      expect(map['isPinned'], true);
      expect(map['createdAt'], isA<String>());
    });

    test('Note.fromMap() tạo Note từ Map', () {
      final map = {
        'title': 'Mapped Note',
        'content': 'Mapped Content',
        'color': 'purple',
        'isPinned': false,
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2025, 1, 2).toIso8601String(),
      };

      final note = Note.fromMap(map, 'mapped-id');

      expect(note.id, 'mapped-id');
      expect(note.title, 'Mapped Note');
      expect(note.content, 'Mapped Content');
      expect(note.color, 'purple');
      expect(note.isPinned, false);
      expect(note.createdAt.year, 2025);
      expect(note.createdAt.month, 1);
      expect(note.createdAt.day, 1);
    });

    test('Note.copyWith() tạo bản sao với thay đổi', () {
      final now = DateTime.now();
      final original = Note(
        id: '4',
        title: 'Original',
        content: 'Original Content',
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        title: 'Modified',
        isPinned: true,
      );

      expect(copy.id, original.id);
      expect(copy.title, 'Modified');
      expect(copy.content, 'Original Content');
      expect(copy.color, original.color);
      expect(copy.isPinned, true);
    });

    test('Note với title rỗng', () {
      final now = DateTime.now();
      final note = Note(
        id: '5',
        title: '',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.title, isEmpty);
      expect(note.content, isNotEmpty);
    });

    test('Note với content rỗng', () {
      final now = DateTime.now();
      final note = Note(
        id: '6',
        title: 'Title',
        content: '',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.title, isNotEmpty);
      expect(note.content, isEmpty);
    });

    test('Note với colors hợp lệ', () {
      final colors = ['blue', 'red', 'green', 'yellow', 'purple', 'orange', 'pink', 'teal'];
      for (var color in colors) {
        final now = DateTime.now();
        final note = Note(
          id: 'color-$color',
          title: 'Test',
          content: 'Test',
          color: color,
          createdAt: now,
          updatedAt: now,
        );
        expect(note.color, color);
      }
    });

    test('Note timestamps hợp lệ', () {
      final createdAt = DateTime(2025, 1, 1);
      final updatedAt = DateTime(2025, 1, 2);
      final note = Note(
        id: '7',
        title: 'Test',
        content: 'Test',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(note.createdAt, createdAt);
      expect(note.updatedAt, updatedAt);
      expect(note.updatedAt.isAfter(note.createdAt), true);
    });

    test('Note.fromMap() xử lý dữ liệu thiếu', () {
      final map = {
        'title': 'Incomplete Note',
        'content': 'Content',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        // Missing color, isPinned
      };

      final note = Note.fromMap(map, 'incomplete-id');

      expect(note.id, 'incomplete-id');
      expect(note.title, 'Incomplete Note');
      expect(note.content, 'Content');
      expect(note.color, 'blue'); // default
      expect(note.isPinned, false); // default
    });
  });
}
