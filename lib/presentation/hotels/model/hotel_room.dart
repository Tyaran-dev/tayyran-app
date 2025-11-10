import 'package:equatable/equatable.dart';

class HotelRoom extends Equatable {
  final int adults;
  final int children;
  final List<int> childrenAges;

  const HotelRoom({
    this.adults = 1,
    this.children = 0,
    this.childrenAges = const [],
  });

  HotelRoom copyWith({int? adults, int? children, List<int>? childrenAges}) {
    return HotelRoom(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      childrenAges: childrenAges ?? this.childrenAges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Adults': adults,
      'Children': children,
      'ChildrenAges': childrenAges,
    };
  }

  @override
  List<Object?> get props => [adults, children, childrenAges];
}
