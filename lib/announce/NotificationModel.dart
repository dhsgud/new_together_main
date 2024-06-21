class AppNotification {
  String id;
  String title;
  String body;
  DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }

  static AppNotification fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      date: map.containsKey('date') ? DateTime.parse(map['date']) : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
