class ChartCreationData {
  String? name;
  DateTime? birthDate;
  int? birthHour;
  int? birthMinute;
  String? birthLocation;
  double? latitude;
  double? longitude;
  String? timezone;

  ChartCreationData({
    this.name,
    this.birthDate,
    this.birthHour,
    this.birthMinute,
    this.birthLocation,
    this.latitude,
    this.longitude,
    this.timezone,
  });

  ChartCreationData copyWith({
    String? name,
    DateTime? birthDate,
    int? birthHour,
    int? birthMinute,
    String? birthLocation,
    double? latitude,
    double? longitude,
    String? timezone,
  }) {
    return ChartCreationData(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
      birthMinute: birthMinute ?? this.birthMinute,
      birthLocation: birthLocation ?? this.birthLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  bool get isComplete {
    return name != null &&
        name!.isNotEmpty &&
        birthDate != null &&
        birthHour != null &&
        birthMinute != null &&
        birthLocation != null &&
        birthLocation!.isNotEmpty;
  }
}
