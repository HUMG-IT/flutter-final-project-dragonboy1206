import 'package:flutter/foundation.dart';
import '../models/note.dart';

// Abstract class định nghĩa interface cho Note Service
abstract class NoteService extends ChangeNotifier {
  List<Note> get notes;
  bool get isLoading;
  bool get isSyncing;
  String? get error;
  String get syncStatus;

  Stream<List<Note>> getNotesStream();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String noteId);
  Future<void> togglePin(Note note);
  List<Note> searchNotes(String query);
}
