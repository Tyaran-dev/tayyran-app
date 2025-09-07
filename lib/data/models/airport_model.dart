// lib/data/models/airport_model.dart
class AirportModel {
  final String id;
  final String text;
  final String name;
  final String city;

  AirportModel({
    required this.id,
    required this.text,
    required this.name,
    required this.city,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    return AirportModel(
      id: json['id'],
      text: json['text'],
      name: json['name'],
      city: json['city'],
    );
  }

  String get displayName => '$id - $name';

  @override
  String toString() => displayName;
}
