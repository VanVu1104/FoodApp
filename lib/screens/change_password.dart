import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showSuccessMessage = false;

  void _saveChanges() {
    setState(() {
      showSuccessMessage = true;
    });

    // Ẩn thông báo sau 2 giây
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showSuccessMessage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Đảm bảo toàn bộ nền trắng
      appBar: AppBar(
        title: Text(
          'Thay đổi mật khẩu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50), // Tăng khoảng cách từ tiêu đề đến form nhập
            _buildTextField(currentPasswordController, 'Mật khẩu hiện tại'),
            _buildTextField(newPasswordController, 'Mật khẩu mới'),
            _buildTextField(confirmPasswordController, 'Nhập lại mật khẩu'),
            SizedBox(height: 10),

            Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 23)),
                ),
                if (showSuccessMessage)
                  Positioned(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lưu thay đổi thành công',
                            style: TextStyle(color: Colors.white, fontSize: 20),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        obscureText: true, // Ẩn mật khẩu
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
}
