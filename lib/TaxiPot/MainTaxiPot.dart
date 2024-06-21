import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:together_project_1/MyPage/LoginPage/LoginPage.dart';
import 'package:together_project_1/TaxiPot/TaxiPotCreatePage/TaxiPotCreatePage.dart';
import 'package:together_project_1/TaxiPot/TaxiPotList/TaxiPotList.dart';
import 'package:together_project_1/TaxiPot/TaxiPotMap/TaxiPotMap.dart';
import 'package:together_project_1/TaxiPot/TaxiPotModel.dart';
import 'package:together_project_1/TaxiPot/TaxiPotSearch/TaxiPotSearch.dart';

class Taxipot extends StatefulWidget {
  @override
  _TaxipotState createState() => _TaxipotState();
}

class _TaxipotState extends State<Taxipot> {
  final DraggableScrollableController _draggableScrollableController = DraggableScrollableController();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool _isUserLoggedIn = false;
  double _maxChildSize = 0.9;
  double _minChildSize = 0.25;
  StreamSubscription? _taxiPotsSubscription;
  List<TaxiPot> taxiPots = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadTaxiPots();
  }

  Future<void> _checkLoginStatus() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 비동기 작업 후 setState 호출
      await Future.delayed(Duration.zero);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  Future<void> _showLoginAlert() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 필요'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('앱을 사용하기 위해서는 로그인이 필요합니다.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        );
      },
    );
  }

  void _loadTaxiPots() {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    _taxiPotsSubscription = ref.child("taxiPots").onValue.listen(
          (event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          List<TaxiPot> loadedTaxiPots = [];
          data.forEach((key, value) {
            loadedTaxiPots.add(TaxiPot.fromMap(Map<String, dynamic>.from(value)));
          });

          if (!mounted) return;
          setState(() {
            taxiPots = loadedTaxiPots;
          });
        }
      },
      onError: (error) {
        // 오류 처리
        print("Firebase 데이터 로드 실패: $error");
      },
    );
  }

  @override
  void dispose() {
    _taxiPotsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(taxiPots),
                );
              },
            ),
            Text('천안'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaxiPotCreatePage()),
                );
              },
              child: Text('팟 만들기'),
            ),
          ],
        ),
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          TaxiPotMap(),
          DraggableScrollableSheet(
            controller: _draggableScrollableController,
            initialChildSize: 0.35, // 시작 크기
            minChildSize: 0.35,     // 최소 크기
            maxChildSize: 1,        // 최대 크기
            snap: true,             // 스냅 활성화
            // snapSizes: [0.35, 0.5, 1], // 스냅 포인트 설정 중간에서도 멈출지 결정 코드
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // 나머지 리스트 컨텐츠
                    Expanded(
                      child: FirebaseDataDisplayPage(
                        scrollController: scrollController,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
