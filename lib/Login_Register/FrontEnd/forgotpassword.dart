import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            myDialogBox(context);
          },
          child: const Text(
            "Quên mật khẩu?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  void showDialogMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    // Kiểm tra định dạng email hợp lệ
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(emailPattern).hasMatch(email);
  }

  void myDialogBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    const Text(
                      "Bạn quên mật khẩu?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Nhập Email của bạn",
                    hintText: "abc@gmail.com",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    String email = emailController.text;

                    // Kiểm tra định dạng email hợp lệ
                    if (!_isValidEmail(email)) {
                      showDialogMessage(
                          context, "Lỗi", "Định dạng email không hợp lệ.");
                      return;
                    }

                    try {
                      await auth
                          .sendPasswordResetEmail(email: email)
                          .then((value) {
                        // Gửi thành công
                        showDialogMessage(context, "Thành công",
                            "Chúng tôi đã gửi liên kết đặt lại mật khẩu đến email của bạn, vui lòng kiểm tra.");
                      });
                    } on FirebaseAuthException catch (e) {
                      // Kiểm tra lỗi khi tài khoản không tồn tại
                      if (e.code == 'user-not-found') {
                        showDialogMessage(
                            context, "Lỗi", "Email không tồn tại.");
                      } else {
                        showDialogMessage(
                            context, "Lỗi", e.message ?? "Đã xảy ra lỗi.");
                      }
                    } catch (e) {
                      showDialogMessage(context, "Lỗi", "Đã xảy ra lỗi: $e");
                    }

                    // Đóng dialog và xóa nội dung email
                    Navigator.pop(context);
                    emailController.clear();
                  },
                  child: const Text(
                    "Gửi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
