import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firebase_service.dart'; // Real Firebase service
// import 'services/mock_firebase_service.dart'; // Mock service - không cần Firebase
import 'services/note_service.dart'; // Base service interface
import 'services/auth_service.dart'; // Auth service
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase (Web không cần firebase_options.dart)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBgWVe2B9Y3uudWnKOpUPydJetjKQwt_Is",
      authDomain: "ghi-chu-f2543.firebaseapp.com",
      projectId: "ghi-chu-f2543",
      storageBucket: "ghi-chu-f2543.firebasestorage.app",
      messagingSenderId: "1008190074656",
      appId: "1:1008190074656:web:b0d86408d5d4d691c8b145",
      measurementId: "G-GSHKRMVM0V",
    ),
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, NoteService>(
          create: (_) => FirebaseService(),
          update: (_, authService, noteService) {
            final firebaseService = noteService as FirebaseService;
            firebaseService.setUserId(authService.currentUser.id);
            return firebaseService;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Ứng Dụng Ghi Chú',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.notoSansTextTheme(),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
