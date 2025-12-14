import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_service.dart';

// Mock Firebase Service - không cần Firebase, data lưu trong memory
class MockFirebaseService extends NoteService {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Chào mừng! 👋',
      content: 'Đây là ứng dụng ghi chú demo. Bạn có thể tạo, sửa, xóa ghi chú ngay bây giờ!\n\nSau khi setup Firebase, dữ liệu sẽ được lưu vào cloud.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      color: 'blue',
      isPinned: true,
    ),
    Note(
      id: '2',
      title: 'Danh sách mua sắm 🛒',
      content: '- Sữa\n- Bánh mì\n- Trứng\n- Rau củ\n- Trái cây',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      color: 'green',
      isPinned: false,
    ),
    Note(
      id: '3',
      title: 'Ý tưởng dự án 💡',
      content: '1. Thêm dark mode\n2. Tích hợp AI\n3. Export PDF\n4. Chia sẻ notes',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      color: 'yellow',
      isPinned: false,
    ),
    Note(
      id: '4',
      title: 'Ghi chú quan trọng ⭐',
      content: 'Nhớ setup Firebase để sync data!\n\nXem hướng dẫn trong FIREBASE_SETUP.md',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      color: 'orange',
      isPinned: true,
    ),
  ];

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String _syncStatus = 'Đã đồng bộ';

  @override
  bool get isSyncing => _isSyncing;
  
  @override
  String get syncStatus => _syncStatus;

  List<Note> get notes {
    // Sort: pinned first, then by updated time
    final sortedNotes = List<Note>.from(_notes);
    sortedNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return sortedNotes;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get notes stream (mock)
  Stream<List<Note>> getNotesStream() async* {
    yield notes;
  }

  // Add note
  Future<void> addNote(Note note) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    final newNote = note.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _notes.add(newNote);

    _isLoading = false;
    notifyListeners();
  }

  // Update note
  Future<void> updateNote(Note note) async {
    if (note.id == null) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Delete note
  Future<void> deleteNote(String noteId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _notes.removeWhere((n) => n.id == noteId);

    _isLoading = false;
    notifyListeners();
  }

  // Toggle pin
  Future<void> togglePin(Note note) async {
    if (note.id == null) return;

    await Future.delayed(const Duration(milliseconds: 200));

    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Search notes
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return notes;

    final lowerQuery = query.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
