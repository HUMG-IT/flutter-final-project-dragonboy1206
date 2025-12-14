import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../constants/colors.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';
import 'login_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<NoteService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _buildUserAvatar(authService),
        title: _searchQuery.isEmpty
            ? const Text(
                'Ghi Chú',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm ghi chú...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
        actions: [
          // Sync status indicator
          _buildSyncIndicator(firebaseService),
          IconButton(
            icon: Icon(
              _searchQuery.isEmpty ? Icons.search : Icons.close,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                if (_searchQuery.isEmpty) {
                  _searchQuery = ' ';
                } else {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
            stream: firebaseService.getNotesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Lỗi: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final notes = snapshot.data ?? [];
              final filteredNotes = _searchQuery.isEmpty || _searchQuery == ' '
                  ? notes
                  : notes.where((note) {
                      final query = _searchQuery.toLowerCase();
                      return note.title.toLowerCase().contains(query) ||
                          note.content.toLowerCase().contains(query);
                    }).toList();

              if (filteredNotes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty || _searchQuery == ' '
                            ? 'Chưa có ghi chú nào'
                            : 'Không tìm thấy ghi chú',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!authService.isLoggedIn && (_searchQuery.isEmpty || _searchQuery == ' ')) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Ghi chú sẽ lưu trên thiết bị',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Đăng nhập để đồng bộ'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isGridView
                    ? _buildGridView(filteredNotes, firebaseService)
                    : _buildListView(filteredNotes, firebaseService),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditNoteScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo ghi chú'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildGridView(List<Note> notes, NoteService service) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index], service);
      },
    );
  }

  Widget _buildListView(List<Note> notes, NoteService service) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index], service);
      },
    );
  }

  Widget _buildNoteCard(Note note, NoteService service) {
    return Card(
      elevation: 2,
      color: NoteColors.getColor(note.color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(note: note),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (note.isPinned)
                        const Icon(
                          Icons.push_pin,
                          size: 18,
                          color: Colors.black54,
                        ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black54,
                        ),
                        onSelected: (value) async {
                          switch (value) {
                            case 'pin':
                              await service.togglePin(note);
                              break;
                            case 'edit':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditNoteScreen(note: note),
                                ),
                              );
                              break;
                            case 'delete':
                              _showDeleteDialog(note, service);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  note.isPinned
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(note.isPinned ? 'Bỏ ghim' : 'Ghim'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: _isGridView ? 6 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(note.updatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Note note, NoteService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.deleteNote(note.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa ghi chú')),
                );
              }
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildUserAvatar(AuthService authService) {
    final user = authService.currentUser;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: CircleAvatar(
          backgroundColor: user.isGuest ? Colors.grey[400] : Colors.blue[700],
          child: user.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        user.getInitials(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  user.getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        itemBuilder: (context) => [
          // User info header
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (user.isGuest)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Chế độ khách',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          
          // Login/Logout button
          if (user.isGuest)
            PopupMenuItem(
              onTap: () {
                // Delay to allow popup to close first
                Future.delayed(Duration.zero, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.login, size: 20, color: Colors.blue),
                  SizedBox(width: 12),
                  Text('Đăng nhập'),
                ],
              ),
            )
          else
            PopupMenuItem(
              onTap: () async {
                // Delay to allow popup to close first
                await Future.delayed(Duration.zero);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await authService.logout();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đăng xuất'),
                      ),
                    );
                  }
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          
          const PopupMenuDivider(),
          
          // Settings (placeholder)
          PopupMenuItem(
            onTap: () {
              Future.delayed(Duration.zero, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng cài đặt đang phát triển'),
                  ),
                );
              });
            },
            child: const Row(
              children: [
                Icon(Icons.settings, size: 20),
                SizedBox(width: 12),
                Text('Cài đặt'),
              ],
            ),
          ),
          
          // About (placeholder)
          PopupMenuItem(
            onTap: () {
              Future.delayed(Duration.zero, () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Ứng Dụng Ghi Chú',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.note_alt_rounded,
                    size: 48,
                    color: Colors.blue,
                  ),
                  children: [
                    const Text(
                      'Ứng dụng ghi chú hiện đại với Firebase backend.',
                    ),
                  ],
                );
              });
            },
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 12),
                Text('Giới thiệu'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị trạng thái đồng bộ
  Widget _buildSyncIndicator(NoteService service) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = authService.isLoggedIn;
    
    // Xác định icon và màu
    IconData icon;
    Color color;
    
    if (service.isSyncing) {
      // Đang đồng bộ
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              service.syncStatus,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    if (service.error != null) {
      icon = Icons.cloud_off;
      color = Colors.red;
    } else if (!isLoggedIn) {
      // Chưa đăng nhập - chưa đồng bộ
      icon = Icons.cloud_off;
      color = Colors.orange;
    } else {
      // Đã đăng nhập - đã đồng bộ
      icon = Icons.cloud_done;
      color = Colors.green;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              service.syncStatus,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
