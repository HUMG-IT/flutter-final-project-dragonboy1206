import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/services/mock_firebase_service.dart';
import 'package:flutter_project/models/note.dart';

void main() {
  group('MockFirebaseService Unit Tests', () {
    late MockFirebaseService service;

    setUp(() {
      service = MockFirebaseService();
    });

    test('Service khởi tạo với danh sách demo', () {
      expect(service.notes, isNotEmpty);
      expect(service.isLoading, false);
      expect(service.error, isNull);
    });

    test('addNote thêm note thành công', () async {
      final initialCount = service.notes.length;
      final now = DateTime.now();
      final note = Note(
        id: '',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      await service.addNote(note);

      expect(service.notes.length, initialCount + 1);
      // Find the added note (not the last one since it might be reordered)
      final addedNote = service.notes.firstWhere((n) => n.title == 'Test Note');
      expect(addedNote.title, 'Test Note');
      expect(addedNote.content, 'Test Content');
      expect(addedNote.id, isNotEmpty);
    });

    test('updateNote cập nhật note thành công', () async {
      final firstNote = service.notes.first;
      final updatedNote = firstNote.copyWith(
        title: 'Updated Title',
        content: 'Updated Content',
      );

      await service.updateNote(updatedNote);

      final found = service.notes.firstWhere((n) => n.id == firstNote.id);
      expect(found.title, 'Updated Title');
      expect(found.content, 'Updated Content');
    });

    test('deleteNote xóa note thành công', () async {
      final initialCount = service.notes.length;
      final noteToDelete = service.notes.first;

      await service.deleteNote(noteToDelete.id!);

      expect(service.notes.length, initialCount - 1);
      expect(service.notes.any((n) => n.id == noteToDelete.id), false);
    });

    test('togglePin chuyển đổi trạng thái pin', () async {
      final note = service.notes.firstWhere((n) => !n.isPinned);
      final originalPinState = note.isPinned;

      await service.togglePin(note);

      final updated = service.notes.firstWhere((n) => n.id == note.id);
      expect(updated.isPinned, !originalPinState);
    });

    test('getNotesStream phát notes stream', () async {
      final stream = service.getNotesStream();
      
      // Only use expectLater, not both expect and await
      expectLater(stream, emits(isA<List<Note>>()));
    });

    test('Notes được sắp xếp: pinned trước', () async {
      final stream = service.getNotesStream();
      final notes = await stream.first;

      // Kiểm tra có notes được pin
      final pinnedNotes = notes.where((n) => n.isPinned).toList();
      expect(pinnedNotes, isNotEmpty);

      // Notes được pin nên ở đầu danh sách
      final firstPinnedIndex = notes.indexWhere((n) => n.isPinned);
      final firstUnpinnedIndex = notes.indexWhere((n) => !n.isPinned);
      
      if (pinnedNotes.isNotEmpty && firstUnpinnedIndex != -1) {
        expect(firstPinnedIndex < firstUnpinnedIndex, true);
      }
    });

    test('Service properties hoạt động', () {
      expect(service.isLoading, isA<bool>());
      expect(service.isSyncing, isA<bool>());
      expect(service.syncStatus, isA<String>());
    });
  });
}
