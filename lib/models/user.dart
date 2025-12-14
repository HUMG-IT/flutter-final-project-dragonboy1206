class User {
  final String? id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isGuest;

  User({
    this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });

  // User mặc định (local/guest)
  factory User.guest() {
    return User(
      email: 'local@user.com',
      displayName: 'Người dùng',
      isGuest: true,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
    };
  }

  // Create from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      isGuest: map['isGuest'] ?? false,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isGuest,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  // Get initials for avatar
  String getInitials() {
    if (displayName.isEmpty) return 'U';
    final names = displayName.split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}
