import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:demo_firebase/Login_Register/BackEnd/auth_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // // Đăng ký tài khoản
  // Future<User?> signUp(String email, String password, String name) async {
  //   try {
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     await userCredential.user?.updateDisplayName(name);
  //     // await userCredential.user?.updateDisplayName(phone);
  //     // await userCredential.user?.updateDisplayName(address);

  //     return userCredential.user;
  //   } catch (e) {
  //     print("Đăng ký thất bại: $e");
  //     return null;
  //   }
  // }

  // Đăng ký tài khoản
  Future<User?> signUp(String email, String password, String name,
      {bool isManager = false}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user?.updateDisplayName(name);

      // Xác định role: Nếu quản lý tạo, role = "staff", nếu tự đăng ký, role = "customer"
      String role = isManager ? "staff" : "customer";
      await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
        "uid": user?.uid,
        "email": email,
        "name": name,
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
        "phone": "",
        "diachi": "",
      }, SetOptions(merge: true));

      return user;
    } catch (e) {
      print("Đăng ký thất bại: $e");
      return null;
    }
  }

  // Đăng nhập
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Đăng nhập thất bại: $e");
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
