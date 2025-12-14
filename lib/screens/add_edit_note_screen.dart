import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../constants/colors.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedColor = 'blue';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề hoặc nội dung')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final firebaseService =
        Provider.of<NoteService>(context, listen: false);

    try {
      final now = DateTime.now();
      
      if (widget.note == null) {
        // Add new note
        final newNote = Note(
          title: _titleController.text.trim().isEmpty
              ? 'Không có tiêu đề'
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: now,
          updatedAt: now,
          color: _selectedColor,
        );
        await firebaseService.addNote(newNote);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tạo ghi chú mới')),
          );
        }
      } else {
        // Update existing note
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text.trim().isEmpty
              ? 'Không có tiêu đề'
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          updatedAt: now,
          color: _selectedColor,
        );
        await firebaseService.updateNote(updatedNote);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật ghi chú')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoteColors.getColor(_selectedColor),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: NoteColors.getColor(_selectedColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Colors.black87),
              onPressed: _saveNote,
            ),
        ],
      ),
      body: Column(
        children: [
          // Color picker
          Container(
            height: 60,
            color: NoteColors.getColor(_selectedColor),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: NoteColors.colorNames.length,
              itemBuilder: (context, index) {
                final colorName = NoteColors.colorNames[index];
                final color = NoteColors.getColor(colorName);
                final isSelected = _selectedColor == colorName;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorName;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.black87,
                            size: 24,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          // Note content
          Expanded(
            child: Container(
              color: NoteColors.getColor(_selectedColor),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tiêu đề',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nội dung ghi chú...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      maxLines: null,
                      minLines: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
