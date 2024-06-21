// lib/boards/free_board_page.dart
import 'package:flutter/material.dart';

class FreeBoardPage extends StatefulWidget {
  @override
  _FreeBoardPageState createState() => _FreeBoardPageState();
}

class _FreeBoardPageState extends State<FreeBoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판'),
      ),
      body: Center(
        // 실제 게시판 글 목록을 표시하게 될 곳
        child: Text('자유게시판의 글이 여기에 표시됩니다.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글 작성 페이지로 이동하는 로직
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
