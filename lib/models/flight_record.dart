class FlightRecord {
  final String id;
  final DateTime date;
  final Duration duree;
  final double altitudeMax;
  final double vitesseMax;

  FlightRecord({
    required this.id,
    required this.date,
    required this.duree,
    required this.altitudeMax,
    required this.vitesseMax,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date.toIso8601String(),
      "dureeSeconds": duree.inSeconds,
      "altitudeMax": altitudeMax,
      "vitesseMax": vitesseMax,
    };
  }

  factory FlightRecord.fromJson(Map<String, dynamic> json) {
    return FlightRecord(
      id: json["id"] as String,
      date: DateTime.parse(json["date"] as String),
      duree: Duration(seconds: json["dureeSeconds"] as int),
      altitudeMax: (json["altitudeMax"] as num).toDouble(),
      vitesseMax: (json["vitesseMax"] as num).toDouble(),
    );
  }
}