import 'package:flutter_naver_map/flutter_naver_map.dart';

class TaxiPotListModel {
  final String id;
  final String startingPoint;
  final String destination;
  final int numberOfParticipants;
  final String departureTime;
  int currentParticipants;
  final int maxParticipants;
  final String creatorId;
  final NLatLng? startingPointLatLng; // NLatLng을 옵셔널(Nullable)로 선언

  TaxiPotListModel({
    required this.id,
    required this.startingPoint,
    required this.destination,
    required this.numberOfParticipants,
    required this.departureTime,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.creatorId,
    this.startingPointLatLng, // 생성자에 추가
  });

  factory TaxiPotListModel.fromMap(Map<String, dynamic> data) {
    // 위도와 경도 값이 null인 경우 기본값 설정
    double latitude = data['latitude'] != null ? double.tryParse(data['latitude']) ?? 0.0 : 0.0;
    double longitude = data['longitude'] != null ? double.tryParse(data['longitude']) ?? 0.0 : 0.0;

    return TaxiPotListModel(
      id: data['id'],
      startingPoint: data['startingPoint'],
      destination: data['destination'],
      numberOfParticipants: data['numberOfParticipants'],
      departureTime: data['departureTime'],
      currentParticipants: data['currentParticipants'],
      maxParticipants: data['maxParticipants'],
      creatorId: data['creatorId'],
      startingPointLatLng: NLatLng(latitude, longitude), // NLatLng 객체 생성
    );
  }
  


}
