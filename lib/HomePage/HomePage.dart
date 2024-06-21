import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:together_project_1/Coupon/Coupon.dart';
import 'package:together_project_1/HomePage/BannerAd/BannerAd.dart';
import 'package:together_project_1/MyPage/MyPage.dart';
import 'package:together_project_1/TasteMap/TasteMap.dart';
import 'package:together_project_1/TaxiPot/MainTaxiPot.dart';
import 'package:together_project_1/announce/Notifications.dart';
import 'package:vibration/vibration.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // 바텀바의 각 탭에 대응하는 페이지 위젯
  final List<Widget> _children = [
    Home(),
    Taxipot(), // Taxipot 페이지를 리스트에 추가
    MyPage()
  ];

  void _onItemTapped(int index) {
    if (Platform.isAndroid) {
      HapticFeedback.lightImpact();
    } else if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _children[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.home),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.local_taxi),
            ),
            label: '실시간 현황',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.person),
            ),
            label: '나의 정보',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            SizedBox(width: 8),
            Image.asset(
              'assets/images/HomeAppBar/AppBar.png', // 이미지 파일
              fit: BoxFit.contain,
              height: 53,
            ), // 이미지와 텍스트 사이의 간격
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 30,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BannerAd(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 1, // 1열로 설정하여 중간 크기로 조정
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 2 / 1, // 중간 크기로 비율 설정
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: <Widget>[
                _buildFeatureItem(Icons.local_taxi, '택시팟', context, Taxipot()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, BuildContext context, Widget destination) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          if (Platform.isAndroid) {
            HapticFeedback.lightImpact();
          } else if (Platform.isIOS) {
            HapticFeedback.lightImpact();
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50),
            Text(label),
          ],
        ),
      ),
    );
  }
}