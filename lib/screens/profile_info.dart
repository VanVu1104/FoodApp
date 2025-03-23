import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileInfoPage extends StatefulWidget {
  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  String email = '';
  bool showSuccessMessage = false;
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  void _saveChanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': usernameController.text,
        'phone': phoneController.text,
        'birthdate': birthdateController.text,
      });

      setState(() {
        showSuccessMessage = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          showSuccessMessage = false;
        });
      });
    }
  }

  Future<void> loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("User uid: $user?.uid");
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          usernameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          birthdateController.text = data['birthdate'] ?? '';
          email = data['email'] ?? '';
          emailController.text = email; // Gán email vào TextEditingController
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thông tin cá nhân',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              SizedBox(height: 10),
              Text('Thy Do',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFD0000))),
              SizedBox(height: 20),
              _buildTextField(usernameController, 'Tên đăng nhập'),
              _buildTextField(phoneController, 'Số điện thoại'),
              _buildTextField(emailController, 'Email'),
              _buildDateField(birthdateController, 'Ngày sinh'),
              SizedBox(height: 20),

              // Bọc nút Lưu thay đổi trong Stack
              Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Lưu thay đổi',
                        style: TextStyle(color: Colors.white, fontSize: 23)),
                  ),
                  if (showSuccessMessage)
                    Positioned(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFFD0000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lưu thay đổi thành công',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 23),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 20, color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(fontSize: 23, color: Colors.grey.shade400),
          floatingLabelStyle: TextStyle(fontSize: 23, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 20, color: Colors.black),
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(fontSize: 23, color: Colors.grey.shade400),
          floatingLabelStyle: TextStyle(fontSize: 23, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          setState(() {
            controller.text = controller.text =
                '${pickedDate?.day.toString().padLeft(2, '0')}/${pickedDate?.month.toString().padLeft(2, '0')}/${pickedDate?.year}';
          });
        },
      ),
    );
  }
}
