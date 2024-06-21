import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:together_project_1/TaxiPot/TaxiPotCardPage/TaxiPotCardPage.dart';
import 'package:together_project_1/TaxiPot/TaxiPotModel.dart';

class FirebaseDataDisplayPage extends StatefulWidget {
  final ScrollController scrollController;

  const FirebaseDataDisplayPage({Key? key, required this.scrollController})
      : super(key: key);

  @override
  _FirebaseDataDisplayPageState createState() =>
      _FirebaseDataDisplayPageState();
}

class _FirebaseDataDisplayPageState extends State<FirebaseDataDisplayPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Widget buildTaxiPotCard(String key, Map<dynamic, dynamic> data) {
    // 변수 선언 및 데이터 처리
    String startingPoint = data['startingPoint'] ?? '';
    String destination = data['destination'] ?? '';
    String departureTime = data['departureTime'] ?? '';
    int participantsCount = (data['participants'] as Map<dynamic, dynamic>?)?.keys.length ?? 0;
    int maxParticipants = data['numberOfParticipants'] is int ? data['numberOfParticipants'] : 0;
    bool isFull = participantsCount >= maxParticipants;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            TaxiPotCardPage(taxiPot: TaxiPot.fromMap(data), taxiPotKey: key)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white, // Container의 배경색을 흰색으로 설정합니다.
          border: Border.all(color: Colors.grey.shade300), // 경계선 색상 설정
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ListTile 사용하여 메인 정보 표시
              ListTile(
                leading: Icon(Icons.directions_car,
                    color: isFull ? Colors.grey : Colors.green),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: startingPoint,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_right_alt, color: Colors.grey),
                        ),
                      ),
                      TextSpan(
                          text: destination,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                ),
                trailing: Text('$participantsCount/$maxParticipants',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
              Divider(color: Colors.grey.shade300),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('참가자 수: $participantsCount',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('출발 시각: $departureTime',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('taxiPots').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Center(child: Text('아직 생성된 팟이 없습니다'));
        } else {
          // 데이터가 Map 타입인지 확인 후 처리
          var data = snapshot.data!.snapshot.value;
          if (data is Map) {
            Map<dynamic, dynamic> values = data;

            if (values.isEmpty) {
              return Center(child: Text('아직 생성된 팟이 없습니다'));
            }

            return ListView.builder(
              controller: widget.scrollController,
              itemCount: values.length,
              itemBuilder: (BuildContext context, int index) {
                String key = values.keys.elementAt(index);
                var data = values[key];

                if (data == null || !(data is Map)) {
                  return SizedBox.shrink(); // 빈 위젯 반환
                }

                return buildTaxiPotCard(key, data);
              },
            );
          } else {
            return Center(child: Text('아직 생성된 팟이 없습니다'));
          }
        }
      },
    );
  }
}
