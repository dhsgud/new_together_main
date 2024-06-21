import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:together_project_1/MyPage/setting/OpenSourceLicensesPage.dart';
import 'package:together_project_1/MyPage/setting/ServiceTermsPage.dart';
import 'package:together_project_1/MyPage/LoginPage/LoginPage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? "사용자";

    return Scaffold(
      appBar: AppBar(
        title: Text('설정 페이지'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    displayName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(Icons.person, color: Colors.green),
                ),
                ListTile(
                  title: Text('회원 탈퇴'),
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
                Divider(), // 구분선 추가
              ],
            ),
          ),
          Divider(), // 하단 구분선 추가
          ListTile(
            title: Text('버전 정보: $_version'),
            leading: Icon(Icons.info, color: Colors.blue),
          ),
          ListTile(
            title: Text('오픈소스 라이선스'),
            leading: Icon(Icons.code, color: Colors.blue),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OpenSourceLicensesPage()),
              );
            },
          ),
          ListTile(
            title: Text('서비스 이용약관'),
            leading: Icon(Icons.description, color: Colors.blue),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServiceTermsPage()),
              );
            },
          ),
          ListTile(
            title: Text('문의 사항'),
            leading: Icon(Icons.phone, color: Colors.blue),
            onTap: () {
              _showContactDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 탈퇴'),
          content: Text('정말 탈퇴하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                _deleteAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('문의 사항'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('전화번호: 010-2531-2074'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      await user?.delete();

      Navigator.of(context).pop(); // Close the dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('회원 탈퇴 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원 탈퇴에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }
}
