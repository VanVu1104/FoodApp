import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Login_Register/FrontEnd/ScreenLoading.dart';
import 'Login_Register/FrontEnd/login.dart'; // Import màn hình đăng nhập
import 'firebase_options.dart'; // Import Firebase options
import 'auth_service.dart';
import 'screens/splash_screen.dart'; // Import màn hình Splash


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
      '/': (context) => SplashScreen(),
       '/login': (context) => AuthScreen(), // Màn hình đăng nhập
      },
    );
  }
}


