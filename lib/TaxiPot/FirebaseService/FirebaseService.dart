import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:together_project_1/TaxiPot/TaxiPotList/TaxiPotListModel.dart';

class FirebaseService {
  static final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  // 참가자 수 업데이트
  static Future<void> updateParticipantsCount(String taxiPotId) async {
    final DatabaseReference taxiPotRef = _databaseReference.child('taxiPots').child(taxiPotId);
    DataSnapshot currentParticipantsSnapshot = await taxiPotRef.child('currentParticipants').get();
    if (currentParticipantsSnapshot.exists) {
      int currentParticipants = int.parse(currentParticipantsSnapshot.value.toString()) + 1;
      await taxiPotRef.child('currentParticipants').set(currentParticipants);
    } else {
      await taxiPotRef.child('currentParticipants').set(1);
    }
  }

  // 채팅방 참가 (FCM 토큰 저장)
  static Future<void> joinChatRoom2(String chatRoomId, String userId) async {
    final DatabaseReference chatRoomRef = _databaseReference.child('chatRooms').child(chatRoomId).child('participants');
    final DatabaseReference userRef = chatRoomRef.child(userId);
    String? token = await getFCMToken();
    if (token != null) {
      await userRef.set({'fcmToken': token});
    }
  }

  // 채팅방 참가 (isActive 상태 설정)
  static Future<void> joinChatRoom(String taxiPotId, String userId) async {
    final DatabaseReference taxiPotRef = _databaseReference.child('taxiPots').child(taxiPotId);
    final DatabaseReference participantsRef = taxiPotRef.child('participants');
    await participantsRef.child(userId).set({'isActive': true});
    await synchronizeParticipants(taxiPotId);
  }

  // 참가자 수 동기화
  static Future<void> synchronizeParticipants(String taxiPotId) async {
    final DatabaseReference participantsRef = _databaseReference.child('taxiPots').child(taxiPotId).child('participants');
    DataSnapshot participantsSnapshot = await participantsRef.get();
    if (participantsSnapshot.value != null) {
      final participantsData = Map<String, dynamic>.from(participantsSnapshot.value as Map);
      int currentParticipants = participantsData.length;
      await participantsRef.parent!.child('currentParticipants').set(currentParticipants);
    }
  }

  // 채팅방 퇴장
  static Future<void> leaveChatRoom(String taxiPotId, String userId) async {
    final DatabaseReference participantsRef = _databaseReference.child('taxiPots').child(taxiPotId).child('participants');
    await participantsRef.child(userId).remove();
    await synchronizeParticipants(taxiPotId);
  }

  // 채팅방 퇴장 (FCM 토큰 삭제)
  static Future<void> leaveChatRoom2(String chatRoomId, String userId) async {
    final DatabaseReference chatRoomRef = _databaseReference.child('chatRooms').child(chatRoomId).child('participants');
    await chatRoomRef.child(userId).remove();
  }

  // FCM 토큰 가져오기

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
  static Future<bool> checkParticipant(String taxiPotId, String userId) async {
    final DatabaseReference participantsRef = _databaseReference.child('taxiPots').child(taxiPotId).child('participants').child(userId);
    DataSnapshot snapshot = await participantsRef.get();
    return snapshot.exists;
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

  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<bool> isUserAlreadyJoined(String roomId, String userId) async {
    final DatabaseReference userRef = _databaseReference
        .child('chatRooms')
        .child(roomId)
        .child('participants')
        .child(userId);

    DatabaseEvent event = await userRef.once();
    return event.snapshot.exists;  // 사용자 노드가 존재하면 참여한 것으로 간주
  }


}
