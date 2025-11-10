import 'package:equatable/equatable.dart';
import 'package:tayyran_app/presentation/hotels/model/hotel_room.dart';

class HotelState extends Equatable {
  final String country;
  final String countryCode;
  final String city;
  final String cityCode;
  final String checkInDate;
  final String checkOutDate;
  final String nationality;
  final String nationalityCode;
  final List<HotelRoom> rooms;
  final bool isLoading;
  final List<dynamic> recentSearches;

  const HotelState({
    this.country = '',
    this.countryCode = '',
    this.city = '',
    this.cityCode = '',
    this.checkInDate = '',
    this.checkOutDate = '',
    this.nationality = '',
    this.nationalityCode = '',
    this.rooms = const [HotelRoom()],
    this.isLoading = false,
    this.recentSearches = const [],
  });

  HotelState copyWith({
    String? country,
    String? countryCode,
    String? city,
    String? cityCode,
    String? checkInDate,
    String? checkOutDate,
    String? nationality,
    String? nationalityCode,
    List<HotelRoom>? rooms,
    bool? isLoading,
    List<dynamic>? recentSearches,
  }) {
    return HotelState(
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      cityCode: cityCode ?? this.cityCode,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      nationality: nationality ?? this.nationality,
      nationalityCode: nationalityCode ?? this.nationalityCode,
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  int get totalRooms => rooms.length;
  int get totalAdults => rooms.fold(0, (sum, room) => sum + room.adults);
  int get totalChildren => rooms.fold(0, (sum, room) => sum + room.children);

  @override
  List<Object?> get props => [
    country,
    countryCode,
    city,
    cityCode,
    checkInDate,
    checkOutDate,
    nationality,
    nationalityCode,
    rooms,
    isLoading,
    recentSearches,
  ];
}
