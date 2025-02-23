import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_firebase/services/auth_service.dart';
import '../screens/screen_home.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _message = "";

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      isManager: false,
    );

    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "email": user.email,
        "name": _nameController.text,
        "phone": "",
        "diachi": "",
        "role": "customer",
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _message = "Đăng ký thành công!";
      });

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)),
      );
    } else {
      setState(() {
        _message = "Đăng ký thất bại! Vui lòng thử lại.";
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập tên người dùng";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập email";
    }
    // Kiểm tra định dạng email
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return "Email không đúng định dạng";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập lại mật khẩu";
    }
    if (value != _passwordController.text) {
      return "Mật khẩu xác nhận không khớp";
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
                Text(
                  "Đăng ký tài khoản",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Nhập thông tin để tạo tài khoản mới",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Họ và Tên",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validateName,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
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
                  validator: _validatePassword,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu",
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Đăng ký", style: TextStyle(fontSize: 16)),
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
