class TaxiPot {
  String id;
  String startingPoint;
  String destination;
  int numberOfParticipants;
  String departureTime;
  int currentParticipants;
  int maxParticipants;
  String creatorId;
  String createdTime;

  TaxiPot({
    this.id = '',
    required this.startingPoint,
    required this.destination,
    required this.numberOfParticipants,
    required this.departureTime,
    this.currentParticipants = 0,
    required this.maxParticipants,
    required this.creatorId,
    required this.createdTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startingPoint': startingPoint,
      'destination': destination,
      'numberOfParticipants': numberOfParticipants,
      'departureTime': departureTime,
      'currentParticipants': currentParticipants,
      'maxParticipants': maxParticipants,
      'creatorId': creatorId,
      'createdTime': createdTime,
    };
  }

  factory TaxiPot.fromMap(Map<dynamic, dynamic> map) {
    return TaxiPot(
      id: map['id'] ?? '',
      startingPoint: map['startingPoint'] ?? '',
      destination: map['destination'] ?? '',
      numberOfParticipants: map['numberOfParticipants'] ?? 0,
      departureTime: map['departureTime'] ?? '',
      currentParticipants: map['currentParticipants'] ?? 0,
      maxParticipants: map['maxParticipants'] ?? 0,
      creatorId: map['creatorId'] ?? '',
      createdTime: map['createdTime'] ?? '',  // 기본값을 ''로 설정
    );
  }
}

bool canJoinChat(TaxiPot taxiPot) {
  return taxiPot.currentParticipants < taxiPot.maxParticipants;
}
