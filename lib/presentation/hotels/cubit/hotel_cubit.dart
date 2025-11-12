import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/services/app_locale.dart';
import 'package:tayyran_app/data/models/city_model.dart';
import 'package:tayyran_app/presentation/hotels/model/hotel_room.dart';
import 'hotel_state.dart';
import 'package:tayyran_app/data/country_data.dart';

class HotelCubit extends Cubit<HotelState> {
  HotelCubit() : super(const HotelState());

  void setCountry(String country, String countryCode) {
    emit(state.copyWith(country: country, countryCode: countryCode, city: ''));
  }

  void setCity(CityModel city) {
    emit(state.copyWith(city: city.name, cityCode: city.code));
  }

  void setCheckInDate(String date) {
    emit(state.copyWith(checkInDate: date));
  }

  void setCheckOutDate(String date) {
    emit(state.copyWith(checkOutDate: date));
  }

  void setNationality(String nationality, String nationalityCode) {
    emit(
      state.copyWith(
        nationality: nationality,
        nationalityCode: nationalityCode,
      ),
    );
  }

  void setRooms(List<HotelRoom> rooms) {
    emit(state.copyWith(rooms: rooms));
  }

  void addRoom() {
    final newRooms = List<HotelRoom>.from(state.rooms)..add(const HotelRoom());
    emit(state.copyWith(rooms: newRooms));
  }

  void removeRoom(int index) {
    if (state.rooms.length > 1) {
      final newRooms = List<HotelRoom>.from(state.rooms)..removeAt(index);
      emit(state.copyWith(rooms: newRooms));
    }
  }

  void updateRoom(int index, HotelRoom room) {
    final newRooms = List<HotelRoom>.from(state.rooms);
    newRooms[index] = room;
    emit(state.copyWith(rooms: newRooms));
  }

  String getCountryCode(String countryName) {
    final allCountries = [...CountryData.countries, ...CountryData.territories];

    // Try to find by Arabic name first
    var country = allCountries.firstWhere(
      (c) => c['name_ar'] == countryName,
      orElse: () => {},
    );

    // If not found, try by English name
    if (country.isEmpty) {
      country = allCountries.firstWhere(
        (c) => c['name_en'] == countryName,
        orElse: () => {},
      );
    }

    return country['code'] ?? 'EG';
  }

  void searchHotels(BuildContext context) {
    emit(state.copyWith(isLoading: true));
    final countryCodeForBackend = state.countryCode.isNotEmpty
        ? state.countryCode
        : 'EG';
    final nationalityCodeForBackend = state.nationalityCode.isNotEmpty
        ? state.nationalityCode
        : countryCodeForBackend;

    final savedLanguage = AppLocale().languageCode;
    print('🔍 Initializing with saved language: $savedLanguage');

    // Prepare the data in the required format
    final requestData = {
      'CityCode': state.cityCode,
      'CheckIn': state.checkInDate,
      'CheckOut': state.checkOutDate,
      'GuestNationality': nationalityCodeForBackend,
      "PreferredCurrencyCode": "SAR",
      "Language": savedLanguage,
      "ResponseTime": 23.0,
      "IsDetailedResponse": true,
      'PaxRooms': state.rooms.map((room) => room.toJson()).toList(),
    };

    print('🏨 Hotel Search Request:');
    print('   Country: ${state.country}');
    print('   City: ${state.city}');
    print('   Check-in: ${state.checkInDate}');
    print('   Check-out: ${state.checkOutDate}');
    print('   Nationality: ${state.nationality}');
    print('   Rooms: ${state.rooms.map((r) => r.toJson()).toList()}');

    // Navigate to search results page with parameters
    _navigateToSearchResults(context, requestData);
  }

  void _navigateToSearchResults(
    BuildContext context,
    Map<String, dynamic> params,
  ) {
    Navigator.pushNamed(
      context,
      RouteNames.hotelSearch,
      arguments: params,
    ).then((_) {
      emit(state.copyWith(isLoading: false));
    });
  }
}
