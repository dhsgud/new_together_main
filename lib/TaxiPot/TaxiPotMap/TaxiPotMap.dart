import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:together_project_1/TaxiPot/TaxiPotMap/CustomFabLocation.dart';
import 'package:together_project_1/TaxiPot/TaxiPotModel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaxiPotMap extends StatefulWidget {
  @override
  _TaxiPotMapState createState() => _TaxiPotMapState();
}

class _TaxiPotMapState extends State<TaxiPotMap> {
  late NaverMapController _controller;
  Position? _currentPosition;
  Map<String, NMarker> _markers = {}; // 마커를 관리하기 위한 맵
  Map<String, NInfoWindow> _infoWindows = {}; // 정보창을 관리하기 위한 맵
  Widget? _infoWindowWidget; // 정보창 위젯을 위한 변수
  NLatLng? _infoWindowPosition; // 정보창 위치를 위한 변수
  String? _openedInfoWindowId;
  @override
  void initState() {
    super.initState();
    _determinePosition();
    _requestLocationPermission();
    _loadTaxiPots();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // 위치 권한 허용됨
    } else if (status.isDenied) {
      print("위치 권한 거부됨");
    }
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }


  void _loadTaxiPots() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('taxiPots');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.value == null) {
      // 데이터가 null인 경우의 처리
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data.forEach((key, value) async {
      final taxiPot = TaxiPot.fromMap(value);
      await _addMarkerWithInfoWindow(taxiPot);
    });
  }



  Future<void> _addMarkerWithInfoWindow(TaxiPot taxiPot) async {
    final coordinates = await _convertAddressToLatLng(taxiPot.startingPoint);
    final markerId = taxiPot.id;
    final marker = NMarker(
      id: markerId,
      position: NLatLng(coordinates.latitude, coordinates.longitude),
    );

    // 정보창 생성 및 추가
    final infoWindow = NInfoWindow.onMarker(
      id: markerId,
      text: '출발지: ${taxiPot.startingPoint}\n목적지: ${taxiPot.destination}\n참가자 수: ${taxiPot.currentParticipants}/${taxiPot.numberOfParticipants}',
    );
    marker.setOnTapListener((NMarker tappedMarker) {
      tappedMarker.openInfoWindow(infoWindow);
      _openedInfoWindowId = markerId; // 현재 열린 정보창의 ID를 저장
      return true;
    });

    // 마커와 정보창을 리스트에 추가
    _markers[markerId] = marker;
    _infoWindows[markerId] = infoWindow;

    // 마커를 컨트롤러에 개별적으로 추가
    if (mounted) {
      _controller.addOverlay(marker);
    }
  }




  Future<NLatLng> _convertAddressToLatLng(String address) async {
    var response = await http.get(
      Uri.parse(
          'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$address'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': '53bjziaqe1',
        'X-NCP-APIGW-API-KEY': '6f3QQD1TQjiqnePJTnbK1QKprwWP45y66Fg7ahjG',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse != null && jsonResponse['addresses'] != null &&
          jsonResponse['addresses'].isNotEmpty) {
        var addressData = jsonResponse['addresses'][0];
        var latitude = double.tryParse(addressData['y']);
        var longitude = double.tryParse(addressData['x']);
        if (latitude != null && longitude != null) {
          return NLatLng(latitude, longitude);
        }
      }
    }
    throw Exception("주소 변환 실패");
  }


  void _moveToCurrentLocation() async {
    if (_currentPosition == null) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (!mounted) return;
      } catch (e) {
        print('위치 정보를 가져오는 데 실패했습니다: $e');
        return;
      }
    }
    try {
      await _controller.updateCamera(NCameraUpdate.withParams(target: NLatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 16));
      final locationOverlay = await _controller.getLocationOverlay();
      locationOverlay.setPosition(NLatLng(_currentPosition!.latitude, _currentPosition!.longitude));
      locationOverlay.setIsVisible(true);
    } catch (e) {
      print('카메라 업데이트 또는 위치 오버레이 가져오기 실패: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        onMapReady: (controller) {
          _controller = controller;
          _moveToCurrentLocation();
        },
        onMapTapped: (point, latLng) {
          if (_openedInfoWindowId != null) {
            final infoWindow = _infoWindows[_openedInfoWindowId];
            if (infoWindow != null) {
              infoWindow.close(); // 정보창 닫기
              _openedInfoWindowId = null; // 현재 열린 정보창 ID 업데이트
            }
          }
        },
        options: NaverMapViewOptions(
          logoAlign: NLogoAlign.leftTop,
          initialCameraPosition: NCameraPosition(
            target: NLatLng(_currentPosition?.latitude ?? 36.815129,
                _currentPosition?.longitude ?? 127.1138939),
            zoom: 12,
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.3,
            child: FloatingActionButton(
              heroTag: 'NaverLocation_tag_1',
              onPressed: _moveToCurrentLocation,
              child: Icon(MdiIcons.crosshairsGps, color: Colors.black),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
          Positioned(
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.3 + 70,
            child: FloatingActionButton(
              heroTag: 'NaverLoading_tag_1',
              onPressed: () {
                _loadTaxiPots();
                // 여기서는 setState를 호출하지 않거나, 필요한 경우만 최소한으로 호출합니다.
              },
              child: Icon(Icons.refresh, color: Colors.black),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
          if (_infoWindowWidget != null && _infoWindowPosition != null)
            _infoWindowWidget!, // 정보창 위젯 표시
        ],
      ),
      floatingActionButtonLocation: CustomFABLocation(
        FloatingActionButtonLocation.endFloat,
        -0.01 * MediaQuery.of(context).size.width,
        -0.01 * MediaQuery.of(context).size.height,
      ),
    );
  }
}