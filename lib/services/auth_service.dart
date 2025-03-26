import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:demo_firebase/Login_Register/BackEnd/auth_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();
  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fetch user information from Firestore
  Future<Map<String, dynamic>?> fetchUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }

  // Update user profile in Firebase Authentication and Firestore
  Future<bool> updateUserProfile(
      {required String uid,
      required String name,
      required String phone,
      required String birthdate}) async {
    try {
      // Update display name in Firebase Authentication
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
      }

      // Update user document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'birthdate': birthdate,
      });

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get user display name
  String getUserDisplayName() {
    return _auth.currentUser?.displayName ?? 'User';
  }

// Phone Number Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<User?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
    String? name,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection("users").doc(user.uid).get();

        if (!userDoc.exists) {
          if (name == null || name.isEmpty) {
            throw Exception("Name is required for new user registration");
          }

          await user.updateDisplayName(name);

          await _firestore.collection("users").doc(user.uid).set({
            "uid": user.uid,
            "phone": user.phoneNumber,
            "name": name,
            "role": "customer",
            "createdAt": FieldValue.serverTimestamp(),
            "diachi": "",
          }, SetOptions(merge: true));
        }
        return user;
      }
      return null;
    } catch (e) {
      print("Phone Sign-In Failed: $e");
      return null;
    }
  }

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        UserCredential userCredential =
            await _auth.signInWithCredential(authCredential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      // Normalize the phone number by removing any potential leading zeros or additional formatting
      String normalizedPhoneNumber =
          phoneNumber.replaceAll(RegExp(r'^(\+84|84|0)'), '+84');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        print("snapshot: ${querySnapshot}");
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

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

  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // Đăng xuất khỏi Google
    await _auth.signOut(); // Đăng xuất khỏi Firebase
  }
}
