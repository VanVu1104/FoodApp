import 'dart:async';
import 'package:demo_firebase/widget/app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final List<String> _images = [
    'assets/banner3.png', // Ảnh banner 1
    'assets/banner4.png', // Ảnh banner 2
    'assets/banner5.png', // Ảnh banner 3
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header cố định
          CustomHeader(),

          // Nội dung chính (gồm cả slider)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Banner Slider
                  SizedBox(
                    height: 200, // Chiều cao banner
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _images.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),

                  // Chỉ báo vị trí slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _images.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Container(
                        width: 8,
                        height: 8,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index ? Colors.red : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),

                  // Nội dung khác
                  Column(
                    children: List.generate(
                      50, // Nội dung dài để cuộn
                      (index) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Nội dung dòng $index',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
