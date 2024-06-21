import 'package:flutter/material.dart';

class MyPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 쓴 글'),
      ),
      body: Center(
        child: Text('내가 쓴 글 페이지 내용'),
      ),
    );
  }
}
