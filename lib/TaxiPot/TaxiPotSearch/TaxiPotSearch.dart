import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:together_project_1/TaxiPot/FirebaseService/FirebaseService.dart';
import 'package:together_project_1/TaxiPot/TaxiPotCardPage/TaxiPotCardPage.dart';
import 'package:together_project_1/TaxiPot/TaxiPotChat/TaxiPotChat.dart';
import 'package:together_project_1/TaxiPot/TaxiPotModel.dart'; // TaxiPotModel 클래스를 import

class CustomSearchDelegate extends SearchDelegate {
  final List<TaxiPot> taxiPots; // TaxiPot 객체 리스트

  CustomSearchDelegate(this.taxiPots);
  final DatabaseReference databaseReference =
  FirebaseDatabase.instance.reference();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _confirmRoomCapacityAndJoin(BuildContext context, String taxiPotId) {
    databaseReference.child('taxiPots').child(taxiPotId).once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        var data = snapshot.value as Map<dynamic, dynamic>;
        int currentParticipants = data['participants']?.length ?? 0;
        int maxParticipants = data['numberOfParticipants'];

        if (currentParticipants < maxParticipants) {
          // 채팅방이 꽉 차지 않았다면, 입장 여부를 묻는 대화 상자 표시
          _showJoinChatDialog(context, taxiPotId);
        } else {
          // 채팅방이 꽉 찼다면, 꽉 찼다는 알림만 표시
          _showFullRoomAlert(context);
        }
      }
    });
  }
  void _showJoinChatDialog(BuildContext context, String taxiPotId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('채팅방 입장'),
          content: Text('채팅방에 입장하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                FirebaseService.joinChatRoom(taxiPotId, currentUserId);
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaxiPotChat(taxiPotId: taxiPotId),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
// 인원 초과 경고 메시지를 표시하는 함수
  void _showFullRoomAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('인원 초과'),
          content: Text('이미 최대 인원수에 도달한 택시팟입니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }


  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // 검색어를 지우고 제안을 다시 표시
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<TaxiPot> matchQuery = [];

    for (var taxiPot in taxiPots) {
      if (taxiPot.startingPoint.toLowerCase().contains(query.toLowerCase()) ||
          taxiPot.destination.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(taxiPot);
      }
    }

    if (matchQuery.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다.'));
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text('출발지: ${result.startingPoint}'),
          subtitle: Text('목적지: ${result.destination}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaxiPotCardPage(
                  taxiPot: result,
                  taxiPotKey: result.id,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 여기에 검색 제안 로직을 구현할 수 있습니다.
    return Container();
  }
}
