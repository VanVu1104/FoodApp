import 'package:demo_firebase/screens/news_screen_1.dart';
import 'package:demo_firebase/screens/news_screen_2.dart';
import 'package:demo_firebase/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'screens/screen_loading.dart';
import 'screens/login.dart'; // Import màn hình đăng nhập
import 'firebase_options.dart'; // Import Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter khởi tạo trước
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Nếu có Firebase CLI setup
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFFFFF), // Màu nền của status bar
      statusBarIconBrightness:
          Brightness.dark, // Icon màu đen (dark) hoặc trắng (light)
    ),
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
        '/': (context) => ScreenLoading1(),
        // '/': (context) => ProfileScreen(),
        // '/': (context) => NewsScreen2(),
        '/login': (context) => AuthScreen(), // Màn hình đăng nhập
      },
    );
  }
}
