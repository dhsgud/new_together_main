import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

const String NAVER_API_KEY = '6f3QQD1TQjiqnePJTnbK1QKprwWP45y66Fg7ahjG';
const String NAVER_CLIENT_ID = '53bjziaqe1';

class NaverMapLocationPicker extends StatefulWidget {
  final Function(NLatLng, String) onLocationSelected;
  final bool isDestination; // 목적지 선택 모드를 나타내는 변수 추가

  NaverMapLocationPicker({
    required this.onLocationSelected,
    this.isDestination = false, // 기본값은 false로 설정
  });

  @override
  _NaverMapLocationPickerState createState() => _NaverMapLocationPickerState();
}

class _NaverMapLocationPickerState extends State<NaverMapLocationPicker> {
  late NaverMapController _mapController;
  NLatLng _center = NLatLng(36.815129, 127.1138939); // 초기 위치
  String _address = '';
  String _fullAddress = '';


  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _moveToCurrentLocation();
    } else {
      print("위치 권한 거부됨");
    }
  }

  void _moveToCurrentLocation() async {
    if (_mapController == null) {
      print('Map Controller is not initialized');
      return;
    }
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final newCenter = NLatLng(position.latitude, position.longitude);
    _mapController.updateCamera(NCameraUpdate.withParams(target: newCenter, zoom: 16));
    _updateCenterAndAddress(newCenter);
  }

  void _onMapCreated(NaverMapController controller) {
    _mapController = controller;
    _moveToCurrentLocation();
  }
  void _updateAddress() async {
    try {
      final result = await _getAddressFromLatLng(_center);
      setState(() {
        _fullAddress = result['fullAddress']; // 전체 주소 저장 (우편번호 포함)
        _address = result['buildingName']; // 화면에는 건물 이름만 표시
      });
    } catch (e) {
      print('주소 업데이트 실패: $e');
    }
  }


  void _updateCenterAndAddress(NLatLng newCenter) async {
    setState(() {
      _center = newCenter;
    });

    try {
      final result = await _getAddressFromLatLng(newCenter);
      setState(() {
        _address = result['address'];
        // 필요한 경우 위도와 경도 정보도 여기에서 사용할 수 있습니다.
        // 예:
        // double latitude = result['latitude'];
        // double longitude = result['longitude'];
      });
    } catch (e) {
      print('주소 업데이트 실패: $e');
    }
  }





  Future<NLatLng> _getLatLngFromAddress(String address) async {
    final response = await http.get(
      Uri.parse(
        'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$address',
      ),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['addresses'] != null && jsonResponse['addresses'].isNotEmpty) {
        final address = jsonResponse['addresses'][0];
        final lat = double.parse(address['y']);
        final lng = double.parse(address['x']);
        return NLatLng(lat, lng);
      } else {
        throw Exception('주소로부터 좌표를 찾을 수 없습니다.');
      }
    } else {
      throw Exception('좌표를 가져오는데 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> _getAddressFromLatLng(NLatLng latLng) async {
    final response = await http.get(
      Uri.parse(
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${latLng.longitude},${latLng.latitude}&orders=roadaddr,addr&output=json',
      ),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': NAVER_CLIENT_ID,
        'X-NCP-APIGW-API-KEY': NAVER_API_KEY,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['results'] != null && jsonResponse['results'].isNotEmpty) {
        String roadAddress = '';
        String postalCode = '';

        var roadAddrResult = jsonResponse['results'].firstWhere(
              (result) => result['name'] == 'roadaddr',
          orElse: () => null,
        );

        if (roadAddrResult != null && roadAddrResult['land'] != null) {
          var addressData = roadAddrResult['land'];
          roadAddress = addressData['name'] ?? '';
          if (addressData['number1'] != null) {
            roadAddress += ' ' + addressData['number1'];
            if (addressData['number2'] != null && addressData['number2'].isNotEmpty) {
              roadAddress += '-' + addressData['number2'];
            }
          }

          postalCode = roadAddrResult['addition1']?['value'] ?? '';
        }

        String fullAddress = postalCode.isNotEmpty ? "$postalCode, $roadAddress" : roadAddress;

        return {
          'fullAddress': fullAddress, // 우편번호가 포함된 전체 주소 반환
          'latitude': latLng.latitude,
          'longitude': latLng.longitude
        };
      } else {
        throw Exception('주소 정보를 찾을 수 없습니다.');
      }
    } else {
      throw Exception('주소를 가져오는데 실패했습니다: 상태 코드 ${response.statusCode}');
    }
  }



  void _confirmLocation() {
    if (_fullAddress.isNotEmpty) {
      widget.onLocationSelected(_center, _fullAddress);
    } else {
      print('주소가 선택되지 않았습니다.');
    }
  }

  void _onCameraIdle() async {
    if (_mapController == null) return;

    final currentPosition = await _mapController.getCameraPosition();
    _center = currentPosition.target;
    _updateAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도에서 위치 선택'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: AddressSearchDelegate(_getLatLngFromAddress)
              );
              if (result != null) {
                final latLng = await _getLatLngFromAddress(result);
                _mapController.updateCamera(NCameraUpdate.withParams(target: latLng, zoom: 16));
                _updateCenterAndAddress(latLng);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          NaverMap(
            onMapReady: _onMapCreated,
            onCameraIdle: _onCameraIdle,
          ),
          Center(
            child: Icon(Icons.place, size: 50, color: Colors.red),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _address.isNotEmpty
                ? Column(
              children: [
                Text('선택된 주소: $_address'),
                ElevatedButton(
                  onPressed: _confirmLocation,
                  child: Text(widget.isDestination ? '목적지 선택 완료' : '출발지 선택 완료'), // 여기서 텍스트 변경
                ),
              ],
            )
                : SizedBox(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pickerlocation1',
        onPressed: _moveToCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }

}
class AddressSearchDelegate extends SearchDelegate<String> {
  final Future<NLatLng?> Function(String) getLatLngFromAddress;

  AddressSearchDelegate(this.getLatLngFromAddress);
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // 빈 문자열 반환
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<NLatLng?>(
      future: getLatLngFromAddress(query), // 수정된 메소드 호출
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListTile(
              title: Text(query),
              onTap: () {
                close(context, query);
              },
            );
          } else {
            return ListTile(
              title: Text('결과 없음'),
              onTap: () {
                close(context, ''); // 빈 문자열 반환
              },
            );
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    // 사용자가 입력하는 동안 제안을 보여주는 위젯
    // 여기서는 구현하지 않았지만, 필요에 따라 구현할 수 있습니다.
    return Container();
  }
}