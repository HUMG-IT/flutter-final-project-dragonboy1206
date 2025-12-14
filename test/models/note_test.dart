import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/models/note.dart';

void main() {
  group('Note Model - Tests quan trọng', () {
    test('Note khởi tạo với đầy đủ thông tin', () {
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
      expect(note.color, 'blue'); // default
      expect(note.isPinned, false); // default
    });

    test('Note.toMap() và fromMap() - Serialize/Deserialize', () {
      final now = DateTime.now();
      final note = Note(
        id: '2',
        title: 'Test',
        content: 'Content',
        color: 'green',
        isPinned: true,
        createdAt: now,
        updatedAt: now,
      );

      // Test toMap
      final map = note.toMap();
      expect(map['title'], 'Test');
      expect(map['color'], 'green');
      expect(map['isPinned'], true);

      // Test fromMap
      final restoredNote = Note.fromMap(map, '2');
      expect(restoredNote.title, note.title);
      expect(restoredNote.content, note.content);
      expect(restoredNote.color, note.color);
    });

    test('Note.copyWith() - Cập nhật thuộc tính', () {
      final now = DateTime.now();
      final note = Note(
        id: '3',
        title: 'Original',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
      );

      final updated = note.copyWith(
        title: 'Updated',
        isPinned: true,
      );

      expect(updated.title, 'Updated');
      expect(updated.isPinned, true);
      expect(updated.id, note.id); // ID không thay đổi
    });
  });
}
