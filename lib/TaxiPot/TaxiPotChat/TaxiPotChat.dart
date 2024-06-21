import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:together_project_1/TaxiPot/FirebaseService/FirebaseService.dart';
import 'package:together_project_1/TaxiPot/TaxiPotChat/TaxiPotChatModel.dart';

class TaxiPotChat extends StatefulWidget {
  final String? taxiPotId;

  const TaxiPotChat({Key? key, this.taxiPotId}) : super(key: key);

  @override
  _TaxiPotChatState createState() => _TaxiPotChatState();
}

class _TaxiPotChatState extends State<TaxiPotChat> {
  List<types.Message> _messages = [];
  late final String _currentUserId;
  StreamSubscription<DatabaseEvent>? _messageSubscription;
  String _announcement = '천안 콜밴 이용시 비용을 절감할 수 있습니다!'; // 공지사항 내용

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _loadMessages();
  }

  void _loadMessages() {
    _messageSubscription = FirebaseDatabase.instance
        .reference()
        .child('chatMessages')
        .child(widget.taxiPotId!)
        .orderByChild('timestamp')
        .onValue
        .listen((event) {
      var messages = <types.Message>[];

      if (event.snapshot.value != null && event.snapshot.value is Map) {
        Map<dynamic, dynamic> data =
        Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        data.entries.forEach((entry) {
          if (entry.value is Map<dynamic, dynamic>) {
            var chatMessage =
            ChatMessage.fromJson(Map<String, dynamic>.from(entry.value));
            var message = types.TextMessage(
              author: types.User(id: chatMessage.senderId),
              createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
              id: entry.key,
              text: chatMessage.message,
            );
            messages.add(message);
          }
        });

        // 시간 순으로 정렬한 후 리스트를 역순으로 설정
        messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt as num));
      }

      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    }, onError: (error) {
      print("Error loading messages: $error");
    });
  }


  void _sendMessage(String text) {
    if (text.isNotEmpty && widget.taxiPotId != null) {
      FirebaseService.sendMessage(widget.taxiPotId!, text, _currentUserId);
    }
  }

  void _showAnnouncement() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('공지사항'),
          content: Text(_announcement),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          stream: FirebaseService.getParticipantCount(widget.taxiPotId ?? ""),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Chat");
            }
            return Text("채팅방 (${snapshot.data} 명 참여중)");
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // 경고 다이얼로그 표시
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('채팅방 나가기'),
                    content: Text('채팅방을 떠나시겠습니까?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('아니오'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그만 닫기
                        },
                      ),
                      TextButton(
                        child: Text('예'),
                        onPressed: () {
                          // 채팅방 떠나는 로직 수행
                          FirebaseService.leaveChatRoom(widget.taxiPotId!, _currentUserId);
                          FirebaseService.leaveChatRoom2(widget.taxiPotId!, _currentUserId);
                          FirebaseService.updateParticipantsCount(widget.taxiPotId!);
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          Navigator.of(context).pop(); // 채팅방 화면 닫기
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 공지사항 탭
          InkWell(
            onTap: _showAnnouncement,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.yellow,
              child: Row(
                children: <Widget>[
                  Icon(Icons.announcement, color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(child: Text(_announcement,
                      style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20), // 여기서 바닥 패딩을 조정
              child: Chat(
                messages: _messages,
                onSendPressed: (types.PartialText text) {
                  _sendMessage(text.text);
                },
                user: types.User(id: _currentUserId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}