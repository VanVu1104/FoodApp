import 'package:demo_firebase/screens/profile_info.dart'; // Import trang profile
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
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Chào mừng, ${user?.displayName ?? 'Người dùng'}!",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 30),

                // Nút chuyển qua trang Profile
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfileInfoPage()), // Chuyển trang
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    "Xem Thông Tin Cá Nhân",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
    );
  }
}
