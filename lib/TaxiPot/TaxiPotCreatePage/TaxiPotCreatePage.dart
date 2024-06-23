import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kpostal/kpostal.dart';
import 'package:together_project_1/TaxiPot/FirebaseService/FirebaseService.dart';
import 'package:together_project_1/TaxiPot/TaxiPotChat/TaxiPotChat.dart';
import 'package:together_project_1/TaxiPot/TaxiPotCreatePage/TaxiPotMaker.dart';
import 'package:together_project_1/TaxiPot/TaxiPotModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String NAVER_API_KEY = '6f3QQD1TQjiqnePJTnbK1QKprwWP45y66Fg7ahjG';
const String NAVER_CLIENT_ID = '53bjziaqe1';

class TaxiPotCreatePage extends StatefulWidget {
  @override
  _TaxiPotCreatePageState createState() => _TaxiPotCreatePageState();
}

class _TaxiPotCreatePageState extends State<TaxiPotCreatePage> {
  String startingPoint = '';
  String destination = '';
  int numberOfParticipants = 1;
  TimeOfDay selectedTime = TimeOfDay.now();
  late NLatLng startingPointLatLng;
  late NLatLng destinationLatLng;
  int currentParticipants = 0;
  String _estimatedArrivalTimeText = '';
  String _estimatedFareText = '';
  late NaverMapController _controller;
  final int baseFare = 4000; // 기본 요금 예시
  final int farePerKm = 1000; // km당 추가 요금 예시
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _startCleanupTimer();
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCleanupTimer() {
    _timer = Timer.periodic(Duration(days: 2), (timer) { //2일이 지나면 팟 삭제
      _cleanupOldRooms();
    });
  }
  Future<void> _cleanupOldRooms() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.child('taxiPots').once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic>? taxiPots = snapshot.value as Map<dynamic, dynamic>?;

    if (taxiPots != null) {
      DateTime now = DateTime.now();
      taxiPots.forEach((key, data) {
        if (data['createdTime'] != null) {
          DateTime createdTime = DateTime.parse(data['createdTime']);
          if (now.isAfter(createdTime.add(Duration(days: 2)))) { // 테스트용 1분
            databaseReference.child('taxiPots/$key').remove();
            databaseReference.child('chatRooms/$key').remove();
            databaseReference.child('chatMessages/$key').remove();
          }
        }
      });
    }
  }
  Future<Map<String, dynamic>> calculateEstimatedTimeAndFare(
      NLatLng startLatLng, NLatLng endLatLng) async {
    if (startingPoint.isEmpty || destination.isEmpty) {
      // 예외 처리 방법
      throw Exception("출발지나 목적지 정보가 누락되었습니다.");

      // 또는 빈 Map 반환 방법
      // return {};
    }
    var response = await http.get(
      Uri.parse(
          'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${startLatLng
              .longitude},${startLatLng.latitude}&goal=${endLatLng
              .longitude},${endLatLng.latitude}&option=taxi'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var route = jsonResponse['route'];
      _displayRouteOnMap(route);
      var durationInMillis = route['traoptimal'][0]['summary']['duration'];
      var distance = route['traoptimal'][0]['summary']['distance'] / 1000;
      var durationInSeconds = durationInMillis / 1000;
      int totalFare = baseFare + (farePerKm * distance).toInt();
      int farePerPerson = (totalFare / numberOfParticipants).ceil();
      int hours = durationInSeconds ~/ 3600;
      int minutes = (durationInSeconds % 3600) ~/ 60;

      return {
        'estimatedTime': hours > 0
            ? '목적지까지 예상 소요시간 : ''${hours}시간 ${minutes}분'
            : '목적지까지 예상 소요시간 : ' '${minutes}분',
        'estimatedFare': '총 ${totalFare}원, 인당 ${farePerPerson}원'
      };
    } else {
      throw Exception("경로 찾기 실패: ${response.statusCode}");
    }
  }

  void _displayRouteOnMap(dynamic route) {
    List<NLatLng> pathPoints = [];
    var path = route['traoptimal'][0]['path'];


    for (var point in path) {
      pathPoints.add(NLatLng(point[1], point[0]));
    }

    final pathOverlay = NPathOverlay(
        id: "routePath",
        coords: pathPoints,
        width: 10,
        color: Colors.blue,
        outlineColor: Colors.black,
        outlineWidth: 2
    );
    _controller.addOverlay(pathOverlay);
  }


  void _convertAddressToLatLng(String address, bool isStartingPoint) async {
    var response = await http.get(
      Uri.parse(
          'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$address'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var latitude = double.parse(jsonResponse['addresses'][0]['y']);
      var longitude = double.parse(jsonResponse['addresses'][0]['x']);
      setState(() {
        if (isStartingPoint) {
          startingPointLatLng = NLatLng(latitude, longitude);
          _controller.updateCamera(NCameraUpdate.withParams(
              target: (startingPointLatLng), zoom: 12));
        } else {
          destinationLatLng = NLatLng(latitude, longitude);
        }
      });
    }
  }

  void _showKpostalDialog(BuildContext context, bool isStartingPoint) async {
    Kpostal? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            KpostalView(
              useLocalServer: false,
              localPort: 8080,
              appBar: AppBar(title: Text("주소 검색")),
            ),
      ),
    );

    // 결과가 null이 아니며, address도 null이 아닌 경우에만 상태 업데이트
    if (result != null && result.address != null) {
      setState(() {
        String address = result.address!;
        if (isStartingPoint) {
          startingPoint = address;
          _convertAddressToLatLng(address, true);
        } else {
          destination = address;
          _convertAddressToLatLng(address, false);
        }
      });
    }
  }


  Future<String?> saveTaxiPot(TaxiPot taxiPot) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child("taxiPots").push();
    taxiPot.id = ref.key!;
    taxiPot.createdTime = DateTime.now().toIso8601String(); // 생성 시간 추가
    await ref.set(taxiPot.toJson());
    return ref.key;
  }


  Future<List<String>> _searchPlaces(String query) async {
    var response = await http.get(
      Uri.parse(
          'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${startingPointLatLng
              .longitude},${startingPointLatLng
              .latitude}&goal=${destinationLatLng.longitude},${destinationLatLng
              .latitude}&option=taxi'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var addresses = jsonResponse['addresses'];
      return List<String>.from(
          addresses.map((address) => address['roadAddress']));
    }
    return [];
  }

  // 출발지와 목적지가 설정되었을 때, 예상 시간과 요금을 계산하고 경로를 표시합니다.
  void _onTimeSelected(TimeOfDay pickedTime) async {
    if (pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });

      // 출발지와 목적지가 설정되었을 때 예상 시간과 요금을 계산합니다.
      if (startingPoint.isNotEmpty && destination.isNotEmpty) {
        try {
          var estimations = await calculateEstimatedTimeAndFare(
              startingPointLatLng, destinationLatLng);
          setState(() {
            _estimatedArrivalTimeText = estimations['estimatedTime'];
            _estimatedFareText = estimations['estimatedFare'];
          });
          _displayRouteOnMap(estimations['route']);
        } catch (e) {
        //  print('Error calculating route info: $e');
        }
      }
    }
  }


  void _onCreateButtonPressed() async {
    if (startingPoint.isEmpty || destination.isEmpty ||
        numberOfParticipants == 0 || selectedTime == TimeOfDay.now()) {
      if (Platform.isAndroid) {
        HapticFeedback.lightImpact();
      } else if (Platform.isIOS) {
        HapticFeedback.lightImpact();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: Text('정보 누락'),
              content: Text('모든 정보를 입력해야 팟을 등록할 수 있습니다.'),
              actions: <Widget>[
                TextButton(
                  child: Text('확인'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
      return;
    }
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final newTaxiPot = TaxiPot(
      startingPoint: startingPoint,
      destination: destination,
      numberOfParticipants: numberOfParticipants,
      departureTime: selectedTime.format(context),
      currentParticipants: 1,
      maxParticipants: 4,
      creatorId: currentUserId,
      createdTime: DateTime.now().toIso8601String(),
    );
    DatabaseReference ref = FirebaseDatabase.instance.reference().child(
        "taxiPots").push();
    newTaxiPot.id = ref.key!;
    await ref.set(newTaxiPot.toJson());
    DatabaseReference participantsRef = FirebaseDatabase.instance.reference()
        .child('taxiPots')
        .child(newTaxiPot.id)
        .child('participants');
    await participantsRef.child(currentUserId).set({'isActive': true});
    FirebaseService.joinChatRoom2(newTaxiPot.id, currentUserId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaxiPotChat(taxiPotId: newTaxiPot.id),
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('택시팟 생성'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
                width: double.infinity,
                height: 250,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 250,
                      child: NaverMap(
                        onMapReady: _onMapReady,
                      ),
                    )
                  ],
                )
            ),
            ListTile(
              title: Text('출발지'),
              subtitle: Text(startingPoint),
              trailing: Icon(Icons.search),
              onTap: () {
                _navigateAndDisplaySelection(context, true); // 출발지 검색을 위한 함수 호출
              },
            ),
            ListTile(
              title: Text('목적지'),
              subtitle: Text(destination),
              trailing: Icon(Icons.search),
              onTap: () {
                _navigateAndDisplaySelection(
                    context, false); // 목적지 검색을 위한 함수 호출
              },
            ),

            ListTile(
              title: Text('참여 인원'),
              subtitle: Text('$currentParticipants/$numberOfParticipants'),
              trailing: DropdownButton<int>(
                value: numberOfParticipants,
                items: [1, 2, 3, 4].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                    if (newValue != null) {
                      numberOfParticipants = newValue;
                      currentParticipants = 1;
                      if (currentUserId == 'mFO3v1LrNXhjyutMhaBZQc4slrX2') {
                        currentParticipants = 0;
                      }
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: Text('출발 시간'),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null) {
                    _onTimeSelected(pickedTime);
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(_estimatedArrivalTimeText),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(_estimatedFareText),
            ),
            ElevatedButton(
              onPressed: _onCreateButtonPressed,
              child: Text('팟 등록'),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapReady(NaverMapController controller) {
    _controller = controller;
  }

  void _navigateAndDisplaySelection(BuildContext context,
      bool isStartingPoint) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationSelectionPage(isStartingPoint: isStartingPoint),
      ),
    );

    if (result != null) {
      setState(() {
        if (isStartingPoint) {
          startingPoint = result;
          _convertAddressToLatLng(result, true);
        } else {
          destination = result;
          _convertAddressToLatLng(result, false);
        }
      });
    }
  }
}