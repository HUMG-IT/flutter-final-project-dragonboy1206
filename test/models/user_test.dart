import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/models/user.dart';

void main() {
  group('User Model Unit Tests', () {
    test('User khởi tạo với thông tin đầy đủ', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        isGuest: false,
      );

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.isGuest, false);
    });

    test('User guest sử dụng factory', () {
      final guestUser = User.guest();

      expect(guestUser.email, 'local@user.com');
      expect(guestUser.displayName, 'Người dùng');
      expect(guestUser.isGuest, true);
    });

    test('User.getInitials() trả về chữ cái đầu', () {
      final user1 = User(
        id: '1',
        email: 'john@example.com',
        displayName: 'John Doe',
        isGuest: false,
      );
      expect(user1.getInitials(), 'JD');

      final user2 = User(
        id: '2',
        email: 'alice@example.com',
        displayName: 'alice',
        isGuest: false,
      );
      expect(user2.getInitials(), 'A');

      final user3 = User(
        id: '3',
        email: 'test@example.com',
        displayName: 'Bob Smith',
        isGuest: false,
      );
      expect(user3.getInitials(), 'BS');
    });

    test('User.getInitials() trả về "U" khi displayName rỗng', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: '',
        isGuest: false,
      );
      expect(user.getInitials(), 'U');
    });

    test('User với email hợp lệ', () {
      final user = User(
        id: 'user456',
        email: 'valid.email@domain.com',
        displayName: 'Valid User',
        isGuest: false,
      );

      expect(user.email, contains('@'));
      expect(user.email, contains('.'));
    });

    test('User với displayName có ký tự đặc biệt', () {
      final user = User(
        id: 'user789',
        email: 'special@example.com',
        displayName: 'Nguyễn Văn Ă',
        isGuest: false,
      );

      expect(user.displayName, 'Nguyễn Văn Ă');
      expect(user.getInitials(), 'NĂ');
    });

    test('User so sánh equality bằng id', () {
      final user1 = User(
        id: 'same-id',
        email: 'user1@example.com',
        displayName: 'User 1',
        isGuest: false,
      );

      final user2 = User(
        id: 'same-id',
        email: 'user2@example.com',
        displayName: 'User 2',
        isGuest: false,
      );

      expect(user1.id, user2.id);
    });

    test('User khác nhau có id khác nhau', () {
      final user1 = User(
        id: 'user1',
        email: 'user1@example.com',
        displayName: 'User 1',
        isGuest: false,
      );

      final user2 = User(
        id: 'user2',
        email: 'user2@example.com',
        displayName: 'User 2',
        isGuest: false,
      );

      expect(user1.id, isNot(user2.id));
    });
  });
}
