// lib/data/models/passenger_info_model.dart
class PassengerInfo {
  final int adults;
  final int children;
  final int infants;

  PassengerInfo({this.adults = 1, this.children = 0, this.infants = 0});

  PassengerInfo copyWith({int? adults, int? children, int? infants}) {
    return PassengerInfo(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
    );
  }

  Map<String, dynamic> toJson() {
    return {'adults': adults, 'children': children, 'infants': infants};
  }

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      adults: json['adults'] as int? ?? 1,
      children: json['children'] as int? ?? 0,
      infants: json['infants'] as int? ?? 0,
    );
  }

  int get totalPassengers => adults + children + infants;

  @override
  String toString() {
    return 'PassengerInfo{adults: $adults, children: $children, infants: $infants }';
  }
}
