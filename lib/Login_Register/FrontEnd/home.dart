import 'package:demo_firebase/Login_Register/BackEnd/auth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/Login_Register/BackEnd/auth_service.dart';
import 'package:demo_firebase/Login_Register/FrontEnd/login.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      userData = widget.userData; // Sử dụng dữ liệu từ widget nếu đã có
    } else {
      _loadUserData(); // Nếu không có, lấy dữ liệu từ Firestore
    }
  }

  // Lấy dữ liệu người dùng từ Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      setState(() {
        userData =
            userDoc.data() as Map<String, dynamic>?; // Cập nhật lại dữ liệu
      });
    }
  }

  // Đăng xuất người dùng
  Future<void> _logOut() async {
    await FirebaseServices().googleSignOut();
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chủ"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logOut,
          ),
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator()) // Đợi dữ liệu
          : Center(
              child: Text(
                "Chào mừng, ${userData?['name'] ?? 'Người dùng'}!", // Hiển thị tên người dùng
                style: TextStyle(fontSize: 20),
              ),
            ),
    );
  }
}
