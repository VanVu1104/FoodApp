import 'package:demo_firebase/services/auth_google.dart';
import 'package:demo_firebase/services/forgot_password.dart';
import 'package:demo_firebase/services/phone_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/services/auth_service.dart';
import 'package:demo_firebase/services/register.dart';
import 'package:demo_firebase/screens/screen_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _message = "";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _rememberMe = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
    _checkAutoLogin();
  }

  //Hàm Load User đã đăng nhập trước đó hay chưa
  void _loadRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Hàm lưu member đã đăng nha
  void _saveRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.clear();
    }
  }

  // Check user đã đăng nhập trước đó hay chưa
  void _checkAutoLogin() async {
    if (_auth.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Hàm đăng ký
  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  // Hàm đăng nhập
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _saveRememberedUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        setState(() {
          _message = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm validate email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập email";
    }
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return "Email không đúng định dạng";
    }
    return null;
  }

  // Hàm validate mật khẩu
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chào mừng bạn!",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Đăng nhập để tiếp tục",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const ForgotPassword(),
                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) =>
                          setState(() => _rememberMe = value!),
                    ),
                    Text('Ghi nhớ mật khẩu')
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                        ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(height: 1, color: Colors.black26)),
                    const Text("  or  "),
                    Expanded(
                        child: Container(height: 1, color: Colors.black26)),
                  ],
                ),

                //Nút đăng nhập bằng Google
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    onPressed: () async {
                      try {
                        User? user =
                            await FirebaseServices().signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(userData: {
                                'name': user.displayName,
                                'email': user.email,
                              }),
                            ),
                          );
                        } else {
                          setState(() {
                            _message = "Đăng nhập với Google bị hủy. Thử lại!";
                          });
                        }
                      } catch (e) {
                        setState(() {
                          _message = "Lỗi đăng nhập: $e";
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.network(
                            "https://ouch-cdn2.icons8.com/VGHyfDgzIiyEwg3RIll1nYupfj653vnEPRLr0AeoJ8g/rs:fit:456:456/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvODg2/LzRjNzU2YThjLTQx/MjgtNGZlZS04MDNl/LTAwMTM0YzEwOTMy/Ny5wbmc.png",
                            height: 35,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Continue with Google",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                //Nút đăng nhập với số điện thoại
                const PhoneAuthentication(),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleSignUp,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Chưa có tài khoản? Đăng ký"),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    _message,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
