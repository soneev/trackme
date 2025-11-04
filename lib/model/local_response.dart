class SessionModel {
  final int? id;
  final String? sessionId;
  final String? startTime;
  final String? endTime;
  final double? distance;
  final bool? synced;
  final List<LocationModel>? locations;

  SessionModel({
    this.id,
    this.sessionId,
    this.startTime,
    this.endTime,
    this.distance,
    this.synced,
    this.locations,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String?,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      distance:
          map['distance'] != null ? (map['distance'] as num).toDouble() : null,
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'start_time': startTime,
      'end_time': endTime,
      'distance': distance,
      'synced': synced == true ? 1 : 0,
    };
  }

  SessionModel copyWith({
    int? id,
    String? sessionId,
    String? startTime,
    String? endTime,
    double? distance,
    bool? synced,
    List<LocationModel>? locations,
  }) {
    return SessionModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      synced: synced ?? this.synced,
      locations: locations ?? this.locations,
    );
  }
}

class LocationModel {
  final int? id;
  final String? sessionId;
  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? accuracy;
  final String? timestamp;
  final bool? synced;

  LocationModel({
    this.id,
    this.sessionId,
    this.latitude,
    this.longitude,
    this.speed,
    this.accuracy,
    this.timestamp,
    this.synced,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String?,
      latitude:
          map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      accuracy:
          map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      timestamp: map['timestamp'] as String?,
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': timestamp,
      'synced': synced == true ? 1 : 0,
    };
  }
}
