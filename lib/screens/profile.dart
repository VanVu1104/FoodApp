import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './profile_info.dart';
import './change_password.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Tài khoản',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            expandedHeight: 250, // Chiều cao phần mở rộng
            floating: false,
            pinned: false, // Cho phép phần này biến mất khi cuộn lên
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 65),
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Thy Do',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 245, 0, 0),
                    ),
                  ),
                  const Text('Điểm tích lũy | 500 điểm',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Divider(
                    color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Tài khoản của tôi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                _buildMenuItem(Icons.person, 'Thông tin cá nhân', context),
                _buildMenuItem(Icons.lock, 'Mật khẩu & Bảo mật', context),
                _buildMenuItem(Icons.history, 'Lịch sử đơn hàng', context),
                _buildMenuItem(Icons.confirmation_number, 'Ưu đãi', context),
                const Divider(
                    color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Thông tin chung',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                _buildMenuItem(
                    Icons.store_mall_directory, 'Danh sách cửa hàng', context),
                _buildMenuItem(Icons.policy, 'Chính sách', context),
                const Divider(
                    color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
                _buildMenuItem(Icons.logout, 'Đăng xuất', context),
                const SizedBox(height: 0),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Tài khoản'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 22)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () {
        if (title == 'Thông tin cá nhân') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileInfoPage()),
          );
        }
        ;
        if (title == 'Mật khẩu & Bảo mật') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangePasswordPage()),
          );
        }
        ;
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Color.fromARGB(255, 251, 224, 222), thickness: 4),
        const SizedBox(height: 10),
        Image.asset(
          'assets/logo.jpg',
          width: 250,
          fit: BoxFit.contain,
        ),
        const Divider(
            color: Color.fromARGB(255, 251, 224, 222),
            thickness: 1,
            indent: 20,
            endIndent: 20),
        const SizedBox(height: 5),
        const Text('Miễn phí giao hàng', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.phone, size: 30),
            SizedBox(width: 10),
            Icon(Icons.language, size: 30),
            SizedBox(width: 10),
            Icon(Icons.smartphone, size: 30),
          ],
        ),
        const SizedBox(height: 5),
        const Divider(
            color: Color.fromARGB(255, 251, 224, 222),
            thickness: 1,
            indent: 20,
            endIndent: 20),
        const Text('Hotline CSKH', style: TextStyle(fontSize: 18)),
        const Text('0906 483 257', style: TextStyle(fontSize: 18)),
        const Divider(
            color: Color.fromARGB(255, 251, 224, 222),
            thickness: 1,
            indent: 20,
            endIndent: 20),
        const SizedBox(height: 10),
        const Text('Kết nối với CRUNCH & DASH', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(FontAwesomeIcons.facebook,
                    color: Colors.blue, size: 30),
                onPressed: () {}),
            IconButton(
                icon: const Icon(FontAwesomeIcons.instagram,
                    color: Colors.purple, size: 30),
                onPressed: () {}),
            IconButton(
                icon: const Icon(FontAwesomeIcons.tiktok,
                    color: Colors.black, size: 30),
                onPressed: () {}),
            IconButton(
                icon: const Icon(FontAwesomeIcons.youtube,
                    color: Colors.red, size: 30),
                onPressed: () {}),
          ],
        ),
      ],
    );
  }
}
