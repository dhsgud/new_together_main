import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:together_project_1/HomePage/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }
}

Future<Map<String, dynamic>> calculateTaxiFare(String start, String destination) async {
  final String clientId = '53bjziaqe1'; // 네이버 클라우드 플랫폼에서 발급받은 Client ID
  final String clientSecret = '6f3QQD1TQjiqnePJTnbK1QKprwWP45y66Fg7ahjG'; // 네이버 클라우드 플랫폼에서 발급받은 Client Secret
  final String requestUrl = 'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving'; // 네이버 지도 API URL

  // HTTP 요청을 구성합니다.
  final response = await http.get(
    Uri.parse('$requestUrl?start=$start&goal=$destination'),
    headers: {
      'X-NCP-APIGW-API-KEY-ID': clientId,
      'X-NCP-APIGW-API-KEY': clientSecret,
    },
  );

  // 응답이 성공적인지 확인하고, 결과를 파싱합니다.
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    // 여기서 data에는 택시 예상 시간 및 비용 정보가 포함되어 있습니다.
    // 예를 들어, data['route']['traoptimal'][0]['summary']['duration']로 예상 시간을 알 수 있습니다.
    return data;
  } else {
    throw Exception('Failed to load data from Naver Maps API');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await NaverMapSdk.instance.initialize(clientId: '53bjziaqe1');
  await NaverMapSdk.instance.initialize(
    clientId: '53bjziaqe1',
    onAuthFailed: (ex) {
      print("********* 네이버맵 인증오류 : $ex *********"); //네이버 맵 초기화
    },
  );

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDbKQ-dQOZ6-8k9MWwqTxMnQw6nzkVShtc',
        appId: '1:717477578053:android:0fee7834fe11496344ea2c', //안드로이드 파이어베이스
        messagingSenderId: '717477578053',
        projectId: 'regsiter-9cffb',
      ),
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDW6fvEm2nbIixqZUXCsLGmXtydk9sdUdk',
        appId: '1:717477578053:ios:825f49b0d48587a044ea2c', //IOS 파이어베이스
        messagingSenderId: '717477578053',
        projectId: 'regsiter-9cffb',
      ),
    );
  }
  await requestLocationPermission();
  runApp(MyApp());
  NotificationService.requestPermission();
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    print("위치 권한 허용됨");
  } else {
    print("위치 권한 거부됨");
    // 권한이 거부되었을 때 필요한 처리를 여기에 추가할 수 있습니다.
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Life',
      theme: ThemeData(
        cardColor: Colors.white,
        primarySwatch: Colors.lightGreen,
      ),
      home: NetworkCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NetworkCheck extends StatefulWidget {
  @override
  _NetworkCheckState createState() => _NetworkCheckState();
}

class _NetworkCheckState extends State<NetworkCheck> {
  List<ConnectivityResult> _connectionStatus = [];

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _connectionStatus = connectivityResult;
    });
  }

  void _showNetworkDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('서비스 연결 상태'),
          content: Text('서비스 연결상태가 좋지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkInternetConnection();
              },
              child: Text('다시 시도'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_connectionStatus.contains(ConnectivityResult.none)) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showNetworkDialog();
      });
    }

    return MyHomePage();
  }
}