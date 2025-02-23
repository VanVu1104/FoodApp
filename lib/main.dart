import 'package:demo_firebase/screens/news_screen_1.dart';
import 'package:demo_firebase/screens/news_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/screen_loading.dart';
import 'screens/login.dart'; // Import màn hình đăng nhập
import 'firebase_options.dart'; // Import Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter khởi tạo trước
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Nếu có Firebase CLI setup
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Route mặc định
      routes: {
        // '/': (context) => ScreenLoading1(),
        '/': (context) => NewsScreen2(),
        '/login': (context) => AuthScreen(), // Màn hình đăng nhập
      },
    );
  }
}
