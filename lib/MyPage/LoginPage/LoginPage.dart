import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:together_project_1/HomePage/HomePage.dart';
import 'package:together_project_1/MyPage/MyPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();




  Future<void> _handleSignInSignUp(bool isSignIn) async {
    try {
      if (isSignIn) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        print('로그인 성공');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        print('계정 생성 성공');
        _showDialog('회원가입 완료', '회원가입이 완료되었습니다! 다시 로그인해주세요.');
      }
    } catch (e) {
      print('${isSignIn ? '로그인' : '계정 생성'} 실패: $e');
      _showDialog('오류', '오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      print('구글 로그인 성공');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } catch (e) {
      print('구글 로그인 실패: $e');
      _showDialog('오류', '오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  Future<void> _showDialog(String title, String content) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Authentication'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyPage())),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleSignInSignUp(true),
              child: Text('로그인'),
            ),
            ElevatedButton(
              onPressed: () => _handleSignInSignUp(false),
              child: Text('회원가입'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleGoogleSignIn,
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/6UgEjh8Xuts4nwdWzTnWH8QtLuHqRMUB7dp24JYVE2xcYzq4HA8hFfcAbU-R-PC_9uA1',
                    height: 24, // 이미지 크기 조정
                    width: 24,
                  ),
                  SizedBox(width: 10), // 이미지와 텍스트 사이 간격
                  Text('구글 로그인'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}