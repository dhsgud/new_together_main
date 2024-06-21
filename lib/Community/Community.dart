import 'package:flutter/material.dart';
import 'package:together_project_1/Community/BestBoardPage/BestBoardPage.dart';
import 'package:together_project_1/Community/CommentsPage/CommentsPage.dart';
import 'package:together_project_1/Community/FreeBoardPage/FreeBoardPage.dart';
import 'package:together_project_1/Community/HotBoardPage/HotBoardPage.dart';
import 'package:together_project_1/Community/MyPostsPage/MyPostsPage.dart';
import 'package:together_project_1/Community/ScrapPage/ScrapPage.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {

  Map<String, bool> pinnedBoards = {}; // 각 게시판의 고정 상태를 저장하는 맵

  @override
  void initState() {
    super.initState();
    // 초기에 모든 게시판을 고정되지 않은 상태로 설정
    pinnedBoards = {
      '자유게시판': false,
      '졸업생게시판': false,
      '새내기게시판': false,
      '시사·이슈': false,
      '장터게시판': false,
      '정보게시판': false,
      '비밀게시판': false,
    };
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('커뮤니티', style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: '게시판'),
              Tab(text: '진로'),
              Tab(text: '홍보'),
              Tab(text: '단체'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildBoardTab(context),
            buildCareerTab(context),
            buildPromotionTab(context),
            buildGroupTab(context),
          ],
        ),
      ),
    );
  }

  Widget buildBoardTab(BuildContext context) {
    return ListView(
      children: <Widget>[
        buildBoardItem(context, '내가 쓴 글', Icons.create, MyPostsPage()),
        buildBoardItem(context, '댓글 단 글', Icons.comment, CommentsPage()),
        buildBoardItem(context, '스크랩', Icons.bookmark, ScrapPage()),
        buildBoardItem(context, 'HOT 게시판', Icons.whatshot, HotBoardPage()),
        buildBoardItem(context, 'BEST 게시판', Icons.grade, BestBoardPage()),
        Divider(color: Colors.grey),
        buildBoardCategory(context, '자유게시판', Icons.push_pin),
        buildBoardCategory(context, '졸업생게시판', Icons.push_pin),
        buildBoardCategory(context, '새내기게시판', Icons.push_pin),
        buildBoardCategory(context, '시사·이슈', Icons.push_pin),
        buildBoardCategory(context, '장터게시판', Icons.push_pin),
        buildBoardCategory(context, '정보게시판', Icons.push_pin),
        buildBoardCategory(context, '비밀게시판', Icons.push_pin),
      ],
    );
  }

  Widget buildBoardCategory(BuildContext context, String title, IconData trailingIcon) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.black)),
      trailing: Icon(trailingIcon, color: Colors.black),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FreeBoardPage()),
        );
      },
    );
  }
  Widget buildPromotionTab(BuildContext context) {
    return ListView(
      children: <Widget>[
        Divider(color: Colors.grey), // 항목들을 구분하는 일자바
      //  buildBoardCategory(context, '동아리 홍보', FreeBoardPage()),
      //  buildBoardCategory(context, '행사 홍보', FreeBoardPage()),
        // ... 추가적인 홍보 관련 카테고리
      ],
    );
  }
  Widget buildCareerTab(BuildContext context) {
    // 진로 탭의 내용 구현
    return Center(child: Text('진로 탭 내용'));
  }
  Widget buildBoardItem(BuildContext context, String title, IconData icon, Widget destinationPage) {
    return Card(
      color: Colors.white, // 카드 배경색을 검은색으로 설정
      child: ListTile(
        leading: Icon(icon, color: Colors.black), // 아이콘 색상을 흰색으로 설정
        title: Text(title, style: TextStyle(color: Colors.black)), // 텍스트 색상을 흰색으로 설정
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        },
      ),
    );
  }
  Widget buildGroupTab(BuildContext context) {
    // 단체 탭의 내용 구현
    return Center(child: Text('단체 탭 내용'));
  }

}