import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  User _currentUser = User.guest();
  bool _isLoading = false;
  String? _error;

  User get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => !_currentUser.isGuest;

  AuthService() {
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? _getDisplayName(firebaseUser.email ?? ''),
          isGuest: false,
        );
      } else {
        _currentUser = User.guest();
      }
      notifyListeners();
    });
  }

  // Register new user
  Future<bool> register(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      _currentUser = User(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        isGuest: false,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _error = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        _error = 'Email đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        _error = 'Email không hợp lệ';
      } else {
        _error = 'Đăng ký thất bại: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Lỗi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = User(
        id: credential.user!.uid,
        email: email,
        displayName: credential.user!.displayName ?? _getDisplayName(email),
        isGuest: false,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _error = 'Không tìm thấy tài khoản';
      } else if (e.code == 'wrong-password') {
        _error = 'Mật khẩu không đúng';
      } else if (e.code == 'invalid-email') {
        _error = 'Email không hợp lệ';
      } else if (e.code == 'user-disabled') {
        _error = 'Tài khoản đã bị vô hiệu hóa';
      } else {
        _error = 'Đăng nhập thất bại: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Lỗi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseAuth.signOut();

      _currentUser = User.guest();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi đăng xuất: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get display name from email
  String _getDisplayName(String email) {
    final name = email.split('@')[0];
    return name[0].toUpperCase() + name.substring(1);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
