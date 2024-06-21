import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kpostal/kpostal.dart';

const String NAVER_API_KEY = '6f3QQD1TQjiqnePJTnbK1QKprwWP45y66Fg7ahjG';
const String NAVER_CLIENT_ID = '53bjziaqe1';

class LocationSelectionPage extends StatefulWidget {
  final bool isStartingPoint; // 출발지 선택인지 목적지 선택인지를 구분

  LocationSelectionPage({Key? key, required this.isStartingPoint})
      : super(key: key);

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  late NaverMapController _mapController;
  String _centerAddress = '주소를 불러오는 중...';
  NLatLng _centerLatLng = NLatLng(36.83420723716653, 127.15406158257744);
  late NaverMapController _controller;
  String startingPoint = '';
  String destination = '';
  int numberOfParticipants = 1;
  TimeOfDay selectedTime = TimeOfDay.now();
  late NLatLng startingPointLatLng;
  late NLatLng destinationLatLng;
  int currentParticipants = 0;
  final int baseFare = 4000; // 기본 요금 예시
  final int farePerKm = 1000; // km당 추가 요금 예시

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getAddressFromLatLng(NLatLng latLng) async {
    final response = await http.get(
      Uri.parse('https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${latLng.longitude},${latLng.latitude}&orders=roadaddr&output=json'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('results') && jsonResponse['results'].isNotEmpty) {
        String address = '';
        String additionalInfo = ''; // 추가 정보를 저장할 변수

        for (var result in jsonResponse['results']) {
          if (result['name'] == 'roadaddr') {
            final roadAddr = result['land'];
            address = roadAddr['name'];
            address += ' ' + roadAddr['number1'];
            if (roadAddr['number2'].isNotEmpty) {
              address += '-' + roadAddr['number2'];
            }

            // 랜드마크나 주변 정보를 추론할 수 있는 추가적인 정보를 포함
            additionalInfo = roadAddr['addition0'].containsKey('value') ? roadAddr['addition0']['value'] : '';
            break;
          }
        }

        if (mounted) { // mounted 상태 확인
          setState(() {
            _centerAddress = address + (additionalInfo.isNotEmpty ? ', ' + additionalInfo : '');
          });
        }
      } else {
        if (mounted) { // mounted 상태 확인
          setState(() {
            _centerAddress = '유효한 주소가 없습니다.';
          });
        }
      }
    } else {
      print('API 호출 실패: ${response.statusCode}');
      if (mounted) { // mounted 상태 확인
        setState(() {
          _centerAddress = '주소를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}';
        });
      }
    }
  }

  void _convertAddressToLatLng(String address, bool isStartingPoint) async {
    var response = await http.get(
      Uri.parse('https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$address'),
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
          _controller.updateCamera(NCameraUpdate.withParams(target: (startingPointLatLng), zoom: 12));
        } else {
          destinationLatLng = NLatLng(latitude, longitude);
        }
      });
    }
  }

  void _openKpostalSearch() async {
    Kpostal? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalView(
          useLocalServer: false,
          localPort: 8080,
          appBar: AppBar(title: Text("주소 검색")),
        ),
      ),
    );

    if (result != null && result.address != null) {
      setState(() {
        _centerAddress = result.address!;
        // _convertAddressToLatLng 함수를 여기서 호출하거나, 필요한 처리를 수행합니다.
        _convertAddressToLatLng(_centerAddress, widget.isStartingPoint);
      });
      Navigator.pop(context, _centerAddress); // 선택된 주소를 반환합니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStartingPoint ? '출발지 검색' : '목적지 검색'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _openKpostalSearch,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          NaverMap(
            onMapReady: (controller) {
              _mapController = controller;
            },
            onCameraIdle: () async {
              final center = await _mapController.getCameraPosition();
              _getAddressFromLatLng(center.target);
            },
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: _centerLatLng,
                zoom: 14,
              ),
            ),
          ),
          const Icon(Icons.location_pin, size: 50), // 중앙 마커 아이콘
          Positioned(
            bottom: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _centerAddress); // 선택된 주소 반환
              },
              child: Text('이 위치 사용'),
            ),
          ),
          Positioned(
            bottom: 80, // '이 위치 사용' 버튼 위에 표시되도록 조정
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(_centerAddress.isNotEmpty ? _centerAddress : '주소를 불러오는 중...',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
