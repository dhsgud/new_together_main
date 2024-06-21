import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:together_project_1/MyPage/LoginPage/LoginPage.dart';
import 'package:together_project_1/MyPage/SettingsPage.dart';
import 'package:together_project_1/TaxiPot/TaxiPotChat/TaxiPotChat.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? "사용자";
    String email = user?.email ?? "이메일 없음";
    String photoURL = user?.photoURL ?? "https://via.placeholder.com/150";
    String currentUserId = user?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text('마이 페이지'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // 설정 페이지로 이동
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(photoURL),
                ),
                SizedBox(height: 10),
                Text(displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                SizedBox(height: 20),
                user != null ? buildLogoutButton(context) : buildLoginSignupButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      icon: Icon(Icons.logout),
      label: Text('로그아웃'),
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
      ),
    );
  }

  Widget buildLoginSignupButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      icon: Icon(Icons.login),
      label: Text('로그인/회원가입'),
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
        onPrimary: Colors.white,
      ),
    );
  }
}