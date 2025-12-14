import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

/// Mock Firebase setup for tests
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

void setupFirebaseCoreMocks() {
  // Use Firebase testing mocks
  setupFirebaseAuthMocks();
}
