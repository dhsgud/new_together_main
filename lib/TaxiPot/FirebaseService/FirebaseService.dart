import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:together_project_1/TaxiPot/TaxiPotList/TaxiPotListModel.dart';

class FirebaseService {
  static final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // 참가자 수 업데이트
  static Future<void> updateParticipantsCount(String taxiPotId) async {
    final DatabaseReference taxiPotsRef = _databaseReference.child('taxiPots');
    DataSnapshot snapshot = await taxiPotsRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> taxiPots = snapshot.value as Map<dynamic, dynamic>;
      for (var taxiPot in taxiPots.entries) {
        if (taxiPot.key == taxiPotId && taxiPot.value is Map) {
          Map<dynamic, dynamic> taxiPotData = taxiPot.value as Map<dynamic, dynamic>;
          if (taxiPotData.containsKey('participants')) {
            Map<dynamic, dynamic> participants = taxiPotData['participants'] as Map<dynamic, dynamic>;
            int currentParticipants = participants.keys.length;
            await taxiPotsRef.child(taxiPotId).child('currentParticipants').set(currentParticipants);
            return;
          }
        }
      }
    }
    await taxiPotsRef.child(taxiPotId).child('currentParticipants').set(0);
  }

  // 현재 참가자 수 가져오기
  static Future<int> getCurrentParticipants(String taxiPotId) async {
    final DatabaseReference taxiPotsRef = _databaseReference.child('taxiPots');
    DataSnapshot snapshot = await taxiPotsRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> taxiPots = snapshot.value as Map<dynamic, dynamic>;
      for (var taxiPot in taxiPots.entries) {
        if (taxiPot.key == taxiPotId && taxiPot.value is Map) {
          Map<dynamic, dynamic> taxiPotData = taxiPot.value as Map<dynamic, dynamic>;
          if (taxiPotData.containsKey('participants')) {
            Map<dynamic, dynamic> participants = taxiPotData['participants'] as Map<dynamic, dynamic>;
            return participants.keys.length;
          }
        }
      }
    }
    return 0;
  }

  // 채팅방 참가 (FCM 토큰 저장)
  static Future<void> joinChatRoom2(String chatRoomId, String userId) async {
    if (Platform.isAndroid) {
      final DatabaseReference chatRoomRef = _databaseReference.child('chatRooms').child(chatRoomId).child('participants');
      final DatabaseReference userRef = chatRoomRef.child(userId);
      String? token = await getFCMToken();
      if (token != null) {
        await userRef.set({'fcmToken': token});
      }
    }
  }

  // 채팅방 참가 (isActive 상태 설정)
  static Future<void> joinChatRoom(String taxiPotId, String userId) async {
    final DatabaseReference taxiPotRef = _databaseReference.child('taxiPots').child(taxiPotId);
    final DatabaseReference participantsRef = taxiPotRef.child('participants');
    await participantsRef.child(userId).set({'isActive': true});
    await updateParticipantsCount(taxiPotId);
  }

  // 채팅방 퇴장
  static Future<void> leaveChatRoom(String taxiPotId, String userId) async {
    final DatabaseReference participantsRef = _databaseReference.child('taxiPots').child(taxiPotId).child('participants');
    await participantsRef.child(userId).remove();
    await updateParticipantsCount(taxiPotId);
  }

  // 채팅방 퇴장 (FCM 토큰 삭제)
  static Future<void> leaveChatRoom2(String chatRoomId, String userId) async {
    if (Platform.isAndroid) {
      final DatabaseReference chatRoomRef = _databaseReference.child('chatRooms').child(chatRoomId).child('participants');
      await chatRoomRef.child(userId).remove();
    }
  }

  // FCM 토큰 가져오기
  static Future<String?> getFCMToken() async {
    if (Platform.isAndroid) {
      return await FirebaseMessaging.instance.getToken();
    } else {
      return null;
    }
  }

  // 참가자 수 감시
  static Stream<int> getParticipantCount(String taxiPotId) {
    final DatabaseReference participantsRef = _databaseReference.child('taxiPots').child(taxiPotId).child('participants');
    return participantsRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return 0;
      } else {
        Map<String, dynamic> participants = Map<String, dynamic>.from(event.snapshot.value as Map);
        return participants.length;
      }
    });
  }

  // 참가자 확인
  static Future<bool> isUserAlreadyJoined(String taxiPotId, String userId) async {
    final DatabaseReference taxiPotsRef = _databaseReference.child('taxiPots');
    DataSnapshot snapshot = await taxiPotsRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> taxiPots = snapshot.value as Map<dynamic, dynamic>;
      for (var taxiPot in taxiPots.entries) {
        if (taxiPot.key == taxiPotId && taxiPot.value is Map) {
          Map<dynamic, dynamic> taxiPotData = taxiPot.value as Map<dynamic, dynamic>;
          if (taxiPotData.containsKey('participants')) {
            Map<dynamic, dynamic> participants = taxiPotData['participants'] as Map<dynamic, dynamic>;
            for (var participant in participants.keys) {
              print(participant);
              if (participant == userId) {
                return true;
              }
            }
          }
        }
      }
    }
    print("User is not joined");
    return false;
  }

  // TaxiPot 정보 가져오기
  static Future<TaxiPotListModel> fetchTaxiPot(String taxiPotId) async {
    final DatabaseReference ref = _databaseReference.child('taxiPots').child(taxiPotId);
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      return TaxiPotListModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
    } else {
      throw Exception('TaxiPot not found');
    }
  }

  // 메시지 전송
  static Future<void> sendMessage(String taxiPotId, String message, String senderId) async {
    final DatabaseReference chatMessagesRef = _databaseReference.child('chatMessages').child(taxiPotId);
    var chatMessage = {
      'message': message,
      'senderId': senderId,
      'timestamp': DateTime.now().millisecondsSinceEpoch, // 현재 시간의 타임스탬프
    };
    await chatMessagesRef.push().set(chatMessage);
  }
}
