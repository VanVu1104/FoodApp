import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'screens/splash_screen.dart'; // Import màn hình Splash

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Định nghĩa route ban đầu là SplashScreen
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => AuthScreen(), // Route màn hình đăng nhập
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = "";

  void _handleSignUp() async {
    var user = await _authService.signUp(
        _emailController.text, _passwordController.text);
    setState(() {
      _message = user != null ? "Đăng ký thành công!" : "Đăng ký thất bại!";
    });
  }

  void _handleSignIn() async {
    var user = await _authService.signIn(
        _emailController.text, _passwordController.text);
    setState(() {
      _message = user != null ? "Đăng nhập thành công!" : "Đăng nhập thất bại!";
    });
  }

  void _handleSignOut() async {
    await _authService.signOut();
    setState(() {
      _message = "Đã đăng xuất!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập Firebase")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _handleSignUp, child: Text("Đăng ký")),
            ElevatedButton(onPressed: _handleSignIn, child: Text("Đăng nhập")),
            ElevatedButton(onPressed: _handleSignOut, child: Text("Đăng xuất")),
            SizedBox(height: 20),
            Text(_message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
