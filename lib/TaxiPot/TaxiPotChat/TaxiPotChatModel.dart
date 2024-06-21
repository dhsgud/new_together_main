class ChatMessage {
  String message;
  String senderId;
  DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.senderId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'senderId': senderId,
      'timestamp': timestamp.millisecondsSinceEpoch, // DateTime을 밀리초 단위 정수로 변환
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      senderId: json['senderId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']), // 밀리초 단위 정수를 DateTime으로 변환
    );
  }
}