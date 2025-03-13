import 'package:demo_firebase/screens/home_screen.dart';
import 'package:demo_firebase/screens/test_screen.dart';
import 'package:flutter/material.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({super.key});

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _pages = [
    // Center(child: Text("🏠 Trang chủ", style: TextStyle(fontSize: 20))),
    // Center(child: Text("❤️ Yêu thích", style: TextStyle(fontSize: 20))),
    // Center(child: Text("🔔 Thông báo", style: TextStyle(fontSize: 20))),
    // Center(child: Text("👤 Tài khoản", style: TextStyle(fontSize: 20))),
    HomeScreen(),
    // NewsScreen1(),
    TestScreen(),
    TestScreen(),
    TestScreen(),
  ];

  final List<IconData> iconList = [
    Icons.home,
    Icons.favorite_border,
    Icons.notifications_none,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      extendBody: true,
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          backgroundColor: Color(0xFFFD0000),
          onPressed: () {
            _fabAnimationController.forward().then((_) {
              Future.delayed(Duration(milliseconds: 200), () {
                _fabAnimationController.reverse();
              });
            });
            print("Nhấn nút giữa!");
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.receipt_long, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: Color(0xFFFD0000),
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Home
              IconButton(
                icon: Icon(Icons.home,
                    size: 32,
                    color: _selectedIndex == 0 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(0),
              ),

              // Icon Yêu thích
              IconButton(
                icon: Icon(Icons.favorite_border,
                    size: 32,
                    color: _selectedIndex == 1 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(1),
              ),

              SizedBox(width: 40), // Khoảng trống giữa các icon (nơi đặt FAB)

              // Icon Thông báo
              IconButton(
                icon: Icon(Icons.notifications_none,
                    size: 32,
                    color: _selectedIndex == 2 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(2),
              ),

              // Icon Hồ sơ cá nhân
              IconButton(
                icon: Icon(Icons.person_outline,
                    size: 32,
                    color: _selectedIndex == 3 ? Colors.white : Colors.white70),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
