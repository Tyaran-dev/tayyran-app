// lib/presentation/hotels/model/city_model.dart
class CityModel {
  final String code;
  final String name;

  CityModel({required this.code, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      code: json['Code']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'Code': code, 'Name': name};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name;

  @override
  int get hashCode => code.hashCode ^ name.hashCode;
}
