import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:together_project_1/TaxiPot/FirebaseService/FirebaseService.dart';
import 'package:together_project_1/TaxiPot/TaxiPotChat/TaxiPotChat.dart';
import 'package:together_project_1/TaxiPot/TaxiPotModel.dart';
import 'package:http/http.dart' as http;
import 'package:together_project_1/global.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

const String NAVER_API_KEY = '6f3QQD1TQjiqnePJTnbK1QKprwWP45y66Fg7ahjG';
const String NAVER_CLIENT_ID = '53bjziaqe1';

class TaxiPotCardPage extends StatefulWidget {
  final TaxiPot taxiPot;
  final String taxiPotKey;

  TaxiPotCardPage({Key? key, required this.taxiPot, required this.taxiPotKey}) : super(key: key);

  @override
  _TaxiPotCardPageState createState() => _TaxiPotCardPageState();
}

class _TaxiPotCardPageState extends State<TaxiPotCardPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String startingPoint = '';
  String destination = '';
  int numberOfParticipants = 1;
  TimeOfDay selectedTime = TimeOfDay.now();
  late NLatLng startingPointLatLng;
  late NLatLng destinationLatLng;
  int currentParticipants = 0;
  late NaverMapController _controller;
  final int baseFare = 4000; // 기본 요금 예시
  final int farePerKm = 1000; // km당 추가 요금 예시
  String _estimatedTime = '';
  String _estimatedFare = '';
  int partiCount = 0;

  Future<void> _launchKakaoT() async {
    const kakaoTUrl = 'kakaot://'; // 카카오 T 앱의 커스텀 URL 스키마
    const kakaoTAndroidStoreUrl = 'https://play.google.com/store/apps/details?id=com.kakao.taxi'; // Android 스토어 URL
    const kakaoTIosStoreUrl = 'https://apps.apple.com/app/id981110422'; // iOS 스토어 URL

    if (await canLaunch(kakaoTUrl)) {
      await launch(kakaoTUrl); // 카카오 T 앱 실행
    } else {
      // 카카오 T 앱이 설치되어 있지 않은 경우 스토어로 이동
      if (Platform.isAndroid) {
        if (await canLaunch(kakaoTAndroidStoreUrl)) {
          await launch(kakaoTAndroidStoreUrl);
        } else {
          print("Could not launch $kakaoTAndroidStoreUrl");
        }
      } else if (Platform.isIOS) {
        if (await canLaunch(kakaoTIosStoreUrl)) {
          await launch(kakaoTIosStoreUrl);
        } else {
          print("Could not launch $kakaoTIosStoreUrl");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateAndDisplayEstimations();
    _initializeParticipantsCount();
  }

  void _initializeParticipantsCount() async {
    final DatabaseReference taxiPotRef = databaseReference.child('taxiPots').child(widget.taxiPotKey);
    DataSnapshot snapshot = await taxiPotRef.child('currentParticipants').get();
    if (snapshot.exists && snapshot.value is int) {
      setState(() {
        currentParticipants = snapshot.value as int;
      });
    } else {
      setState(() {
        currentParticipants = 0;
      });
    }
  }

  Future<Map<String, dynamic>> calculateEstimatedTimeAndFare(NLatLng startLatLng, NLatLng endLatLng) async {
    var response = await http.get(
      Uri.parse('https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${startLatLng.longitude},${startLatLng.latitude}&goal=${endLatLng.longitude},${endLatLng.latitude}&option=taxi'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var route = jsonResponse['route'];
      _displayRouteOnMap(route);
      var durationInMillis = route['traoptimal'][0]['summary']['duration']; // 밀리초 단위로 제공되는 duration
      var distance = route['traoptimal'][0]['summary']['distance'] / 1000; // 거리를 km 단위로 변환

      var durationInSeconds = durationInMillis / 1000;
      int totalFare = baseFare + (farePerKm * distance).toInt();
      int farePerPerson = (totalFare / numberOfParticipants).ceil();
      int hours = durationInSeconds ~/ 3600;
      int minutes = (durationInSeconds % 3600) ~/ 60;

      return {
        'estimatedTime': hours > 0 ? '${hours}시간 ${minutes}분' : '${minutes}분',
        'estimatedFare': '총 ${totalFare}원, 인당 ${farePerPerson}원'
      };
    } else {
      throw Exception("경로 찾기 실패: ${response.statusCode}");
    }
  }

  void _showCheonanCallVanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('천안 콜밴'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('카카오톡 ID: jdcall2015')),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'jdcall2015'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('카카오톡 ID가 복사되었습니다.')),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('전화번호: 010-8596-7550')),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '010-8596-7550'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('전화번호가 복사되었습니다.')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _calculateAndDisplayEstimations() async {
    try {
      NLatLng startLatLng = await convertAddressToLatLng(widget.taxiPot.startingPoint);
      NLatLng endLatLng = await convertAddressToLatLng(widget.taxiPot.destination);

      var estimations = await calculateEstimatedTimeAndFare(startLatLng, endLatLng);
      setState(() {
        _estimatedTime = estimations['estimatedTime'];
        // 참가자 수(maxParticipants)를 기준으로 인당 요금 계산
        int totalFare = int.parse(estimations['estimatedFare'].split(" ")[1].replaceAll("원,", ""));
        _estimatedFare = '총 ${totalFare}원, 인당 ${(totalFare / widget.taxiPot.numberOfParticipants).ceil()}원';
        startingPointLatLng = startLatLng;
      });
      if (_controller != null) {
        _controller.updateCamera(NCameraUpdate.withParams(target: startingPointLatLng, zoom: 12));
      }
    } catch (e) {
      print('Estimation error: $e');
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
        outlineWidth: 2);
    _controller.addOverlay(pathOverlay);
  }

  Future<NLatLng> convertAddressToLatLng(String address) async {
    final queryParameters = {
      'query': address,
    };
    final uri = Uri.https(
      'naveropenapi.apigw.ntruss.com',
      '/map-geocode/v2/geocode',
      queryParameters,
    );
    final headers = {
      'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
      'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['addresses'].isNotEmpty) {
        final addressInfo = jsonResponse['addresses'][0];
        final latitude = double.parse(addressInfo['y']);
        final longitude = double.parse(addressInfo['x']);
        return NLatLng(latitude, longitude);
      } else {
        throw Exception("주소 변환 실패");
      }
    } else {
      throw Exception("API 요청 실패: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('팟 상세 정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: NaverMap(
                      onMapReady: _onMapReady,
                    ),
                  ),
                  Text('출발지: ${widget.taxiPot.startingPoint}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('목적지: ${widget.taxiPot.destination}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  StreamBuilder<int>(
                    stream: FirebaseService.getParticipantCount(widget.taxiPotKey),
                    builder: (context, snapshot) {
                      int participantsCount = snapshot.data ?? 0;
                      return Text('참여 인원: $participantsCount/${widget.taxiPot.numberOfParticipants}', style: TextStyle(fontSize: 16));
                    },
                  ),
                  SizedBox(height: 8),
                  Text('예상 소요 시간: $_estimatedTime'),
                  SizedBox(height: 8),
                  Text('예상 요금: $_estimatedFare'),
                  SizedBox(height: 8),
                  Text('출발 시각: ${widget.taxiPot.departureTime}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 첫 번째 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FloatingActionButton.extended(
              heroTag: 'chatRoomButtonsreal',
              onPressed: () async {
                String userId = FirebaseAuth.instance.currentUser!.uid;
                bool isAlreadyJoined = await FirebaseService.isUserAlreadyJoined(widget.taxiPotKey, userId);
                int currentParticipants = await FirebaseService.getCurrentParticipants(widget.taxiPotKey);
                print(currentParticipants);
                print(isAlreadyJoined);
                if (!isAlreadyJoined && currentParticipants >= widget.taxiPot.numberOfParticipants) {
                  _showFullRoomAlert(context);
                } else {
                  if (mounted) {
                    _showJoinChatDialog(context, widget.taxiPotKey);
                  }
                }
              },
              label: Text('채팅방 입장'),
              icon: Icon(Icons.chat),
            ),
          ),
          // 두 번째 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FloatingActionButton.extended(
              heroTag: 'launchkakaotaxi',
              onPressed: _launchKakaoT,
              label: Text('카카오 T'),
              icon: Icon(Icons.directions_car), // 카카오 T 아이콘
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FloatingActionButton.extended(
              heroTag: 'chenonancallban',
              onPressed: () => _showCheonanCallVanDialog(context),
              label: Text('천안 콜밴'),
              icon: Icon(Icons.directions_car), // 카카오 T 아이콘
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onMapReady(NaverMapController controller) {
    _controller = controller;
    if (startingPointLatLng != null) {
      _controller.updateCamera(NCameraUpdate.withParams(target: startingPointLatLng, zoom: 12));
    }
  }

  Future<void> _showJoinChatDialog(BuildContext context, String roomId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

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
              onPressed: () async {
                await FirebaseService.joinChatRoom2(roomId, userId);
                await FirebaseService.joinChatRoom(roomId, userId);
                if (!mounted) return; // context가 유효한지 확인
                await FirebaseService.updateParticipantsCount(roomId); // 참가자 수 업데이트
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaxiPotChat(taxiPotId: roomId),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


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
}
