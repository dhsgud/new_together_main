import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> _getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  return token;
}

Future<void> _saveParticipantInfo(String? userId, String? token) async {
  if (userId == null || token == null) return;

  DatabaseReference ref = FirebaseDatabase.instance.ref("participants/$userId");

  await ref.set({
    'fcmToken': token,
    // 추가 참가자 정보 필드는 여기에 추가
  });
}

void _updateUserToken() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? userId = currentUser?.uid; // 현재 사용자의 UID
  String? token = await _getFCMToken();

  await _saveParticipantInfo(userId, token);
}