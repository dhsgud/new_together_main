import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:together_project_1/announce/NotificationModel.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final DatabaseReference notificationsRef =
      FirebaseDatabase.instance.reference().child('notifications');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
      ),
      body: StreamBuilder(
        stream: notificationsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Map<dynamic, dynamic> values =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ?? {};
          List<AppNotification> notifications = values.entries.map((entry) {
            return AppNotification.fromMap(
                Map<String, dynamic>.from(entry.value), entry.key);
          }).toList();

          int unreadCount = notifications
              .where((notification) => !notification.isRead)
              .length;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    AppNotification notification = notifications[index];
                    return ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.body),
                      trailing: Text(
                          DateFormat('yyyy-MM-dd').format(notification.date)),
                      onTap: () {
                        setState(() {
                          notification.isRead = true;
                          notificationsRef
                              .child(notification.id)
                              .update({'isRead': true});
                        });
                      },
                      tileColor:
                          notification.isRead ? Colors.white : Colors.grey[200],
                    );
                  },
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.red,
                  child: Text('$unreadCount 미읽은 알림'),
                ),
            ],
          );
        },
      ),
    );
  }
}
