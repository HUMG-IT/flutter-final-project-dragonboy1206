import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import 'note_service.dart';

class FirebaseService extends NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notes';
  String? _userId;
  
  List<Note> _notes = [];
  List<Note> _localNotes = []; // Notes khi chưa đăng nhập
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String _syncStatus = 'Chưa đồng bộ'; // Mặc định chưa đăng nhập

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String get syncStatus => _syncStatus;

  // Set user ID for filtering notes
  Future<void> setUserId(String? userId) async {
    final oldUserId = _userId;
    _userId = userId;
    
    // Cập nhật sync status theo trạng thái đăng nhập
    if (userId == null || userId.isEmpty) {
      _syncStatus = 'Chưa đồng bộ';
    } else {
      _syncStatus = 'Đã đồng bộ';
    }
    
    // Nếu chuyển từ guest sang logged in, sync local notes lên Firebase
    if (oldUserId == null && userId != null && _localNotes.isNotEmpty) {
      await _syncLocalNotesToFirebase();
    }
    
    notifyListeners();
  }
  
  // Sync local notes lên Firebase khi đăng nhập
  Future<void> _syncLocalNotesToFirebase() async {
    if (_userId == null || _localNotes.isEmpty) return;
    
    try {
      _isSyncing = true;
      _syncStatus = 'Đang đồng bộ ghi chú...';
      notifyListeners();
      
      for (final note in _localNotes) {
        final noteData = note.toMap();
        noteData['userId'] = _userId;
        await _firestore.collection(_collection).add(noteData);
      }
      
      _localNotes.clear();
      _isSyncing = false;
      _syncStatus = 'Đã đồng bộ ${_localNotes.length} ghi chú';
      notifyListeners();
      
      // Reset về trạng thái bình thường sau 2 giây
      await Future.delayed(const Duration(seconds: 2));
      _syncStatus = 'Đã đồng bộ';
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi đồng bộ: $e';
      _isSyncing = false;
      _syncStatus = 'Lỗi đồng bộ';
      notifyListeners();
    }
  }

  // Get all notes ordered by pinned status and updated time
  Stream<List<Note>> getNotesStream() {
    // If no userId, return local notes stream (guest mode)
    if (_userId == null || _userId!.isEmpty) {
      return Stream.periodic(const Duration(milliseconds: 100), (_) {
        final sortedNotes = List<Note>.from(_localNotes);
        sortedNotes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.updatedAt.compareTo(a.updatedAt);
        });
        return sortedNotes;
      }).distinct();
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map((doc) {
        return Note.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort in-memory: pinned notes first, then by updatedAt
      notes.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
      
      return notes;
    });
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    // Nếu chưa đăng nhập, lưu vào local
    if (_userId == null || _userId!.isEmpty) {
      try {
        _isLoading = true;
        _error = null;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 300));
        
        final newNote = note.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        _localNotes.add(newNote);
        
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
      return;
    }

    // Đã đăng nhập, lưu lên Firebase
    try {
      _isLoading = true;
      _isSyncing = true;
      _error = null;
      _syncStatus = 'Đang đồng bộ...';
      notifyListeners();

      final noteData = note.toMap();
      noteData['userId'] = _userId;
      
      await _firestore.collection(_collection).add(noteData);
      
      _isLoading = false;
      _isSyncing = false;
      _syncStatus = 'Đã đồng bộ';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isSyncing = false;
      _syncStatus = 'Lỗi đồng bộ';
      notifyListeners();
      rethrow;
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    if (note.id == null) return;
    
    // Nếu chưa đăng nhập, cập nhật local
    if (_userId == null || _userId!.isEmpty) {
      try {
        _isLoading = true;
        _error = null;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 300));
        
        final index = _localNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _localNotes[index] = note;
        }
        
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
      return;
    }
    
    // Đã đăng nhập, cập nhật Firebase
    try {
      _isLoading = true;
      _isSyncing = true;
      _error = null;
      _syncStatus = 'Đang cập nhật...';
      notifyListeners();

      await _firestore
          .collection(_collection)
          .doc(note.id)
          .update(note.toMap());
      
      _isLoading = false;
      _isSyncing = false;
      _syncStatus = 'Đã đồng bộ';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isSyncing = false;
      _syncStatus = 'Lỗi cập nhật';
      notifyListeners();
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    // Nếu chưa đăng nhập, xóa local
    if (_userId == null || _userId!.isEmpty) {
      try {
        _isLoading = true;
        _error = null;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 300));
        
        _localNotes.removeWhere((n) => n.id == noteId);
        
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
      return;
    }
    
    // Đã đăng nhập, xóa khỏi Firebase
    try {
      _isLoading = true;
      _isSyncing = true;
      _error = null;
      _syncStatus = 'Đang xóa...';
      notifyListeners();

      await _firestore.collection(_collection).doc(noteId).delete();
      
      _isLoading = false;
      _isSyncing = false;
      _syncStatus = 'Đã đồng bộ';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isSyncing = false;
      _syncStatus = 'Lỗi xóa';
      notifyListeners();
      rethrow;
    }
  }

  // Toggle pin status
  Future<void> togglePin(Note note) async {
    if (note.id == null) return;
    
    // Nếu chưa đăng nhập, cập nhật local
    if (_userId == null || _userId!.isEmpty) {
      final index = _localNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _localNotes[index] = note.copyWith(
          isPinned: !note.isPinned,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      return;
    }
    
    // Đã đăng nhập, cập nhật Firebase
    try {
      await _firestore.collection(_collection).doc(note.id).update({
        'isPinned': !note.isPinned,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search notes
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    
    final lowerQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
