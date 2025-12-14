import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/models/user.dart';

void main() {
  group('User Model - Tests quan trọng', () {
    test('User khởi tạo với thông tin đầy đủ', () {
      final user = User(
        id: 'user1',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(user.id, 'user1');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.isGuest, false);
    });

    test('User.guest() tạo tài khoản khách', () {
      final guest = User.guest();

      expect(guest.email, 'local@user.com');
      expect(guest.displayName, 'Người dùng');
      expect(guest.isGuest, true);
    });

    test('User.getInitials() trả về chữ cái đầu', () {
      final user = User(
        id: 'user2',
        email: 'john@example.com',
        displayName: 'John Doe',
      );

      expect(user.getInitials(), 'JD');
    });
  });
}
