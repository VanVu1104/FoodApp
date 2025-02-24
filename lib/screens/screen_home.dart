import 'package:demo_firebase/services/auth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_firebase/services/auth_service.dart';
import 'package:demo_firebase/screens/login.dart';

class HomeScreen extends StatefulWidget {
  Map<String, dynamic>? userData;

  HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
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
      body: user == null
          ? Center(child: CircularProgressIndicator()) // Đợi dữ liệu
          : Center(
              child: Text(
                "Chào mừng, ${user?.displayName ?? 'Người dùng'}!", // Hiển thị tên người dùng
                style: TextStyle(fontSize: 20),
              ),
            ),
    );
  }
}
