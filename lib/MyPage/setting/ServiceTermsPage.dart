import 'package:flutter/material.dart';
import 'package:together_project_1/MyPage/setting/LocationServiceTermsPage.dart';
import 'package:together_project_1/MyPage/setting/PrivacyPolicyPage.dart';
import 'package:together_project_1/MyPage/setting/TermsOfServicePage.dart';


class ServiceTermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('서비스 이용약관'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('개인정보처리방침'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            title: Text('위치기반서비스 이용약관'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationServiceTermsPage()),
              );
            },
          ),
          ListTile(
            title: Text('서비스 이용약관'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsOfServicePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}