// lib/core/services/app_service.dart
import 'package:flutter/foundation.dart';
import 'package:tayyran_app/data/models/airport_model.dart';
import 'package:tayyran_app/data/models/flight_destination_model.dart';
import 'package:tayyran_app/data/models/passenger_info_model.dart';

class AppService {
  // Private constructor
  AppService._internal();

  // Singleton instance
  static final AppService _instance = AppService._internal();

  // Factory constructor
  factory AppService() => _instance;

  // --- Application State ---
  String _selectedLanguage = 'en';
  String _tripType = 'one-way'; // 'one-way', 'round-trip', 'multi-city'

  // --- Flight Search Parameters ---
  final List<FlightDestination> _destinations = [];
  PassengerInfo _passengerInfo = PassengerInfo();

  // --- Current Selections ---
  AirportModel? _selectedFromAirport;
  AirportModel? _selectedToAirport;
  DateTime? _selectedDepartureDate;
  DateTime? _selectedReturnDate;

  // --- Listeners ---
  final List<VoidCallback> _listeners = [];

  // --- Getters ---
  String get selectedLanguage => _selectedLanguage;
  String get tripType => _tripType;
  List<FlightDestination> get destinations => List.unmodifiable(_destinations);
  PassengerInfo get passengerInfo => _passengerInfo;
  AirportModel? get selectedFromAirport => _selectedFromAirport;
  AirportModel? get selectedToAirport => _selectedToAirport;
  DateTime? get selectedDepartureDate => _selectedDepartureDate;
  DateTime? get selectedReturnDate => _selectedReturnDate;

  // --- Setters with notification ---
  set selectedLanguage(String value) {
    _selectedLanguage = value;
    _notifyListeners();
  }

  set tripType(String value) {
    _tripType = value;
    _notifyListeners();
  }

  set passengerInfo(PassengerInfo value) {
    _passengerInfo = value;
    _notifyListeners();
  }

  set selectedFromAirport(AirportModel? value) {
    _selectedFromAirport = value;
    _notifyListeners();
  }

  set selectedToAirport(AirportModel? value) {
    _selectedToAirport = value;
    _notifyListeners();
  }

  set selectedDepartureDate(DateTime? value) {
    _selectedDepartureDate = value;
    _notifyListeners();
  }

  set selectedReturnDate(DateTime? value) {
    _selectedReturnDate = value;
    _notifyListeners();
  }

  // --- Destination Management ---
  void addDestination(FlightDestination destination) {
    _destinations.add(destination);
    _notifyListeners();
  }

  void updateDestination(String id, FlightDestination updatedDestination) {
    final index = _destinations.indexWhere((d) => d.id == id);
    if (index != -1) {
      _destinations[index] = updatedDestination;
      _notifyListeners();
    }
  }

  void removeDestination(String id) {
    _destinations.removeWhere((d) => d.id == id);
    _notifyListeners();
  }

  void clearAllDestinations() {
    _destinations.clear();
    _notifyListeners();
  }

  FlightDestination? getDestination(String id) {
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- Passenger Management ---
  void updatePassengerInfo({
    int? adults,
    int? children,
    int? infants,
    String? cabinClass,
  }) {
    _passengerInfo = _passengerInfo.copyWith(
      adults: adults,
      children: children,
      infants: infants,
    );
    _notifyListeners();
  }

  // --- Helper Methods ---
  bool get isRoundTrip => _tripType == 'round-trip';
  bool get isMultiCity => _tripType == 'multi-city';
  bool get isOneWay => _tripType == 'one-way';

  int get totalDestinations => _destinations.length;

  // --- Search Parameters Preparation ---
  Map<String, dynamic> toSearchJson() {
    if (isMultiCity) {
      return {
        'tripType': _tripType,
        'destinations': _destinations.map((d) => d.toJson()).toList(),
        'passengers': _passengerInfo.toJson(),
        'language': _selectedLanguage,
      };
    } else {
      return {
        'tripType': _tripType,
        'from': _selectedFromAirport?.id ?? '',
        'to': _selectedToAirport?.id ?? '',
        'departureDate': _selectedDepartureDate?.toIso8601String().split(
          'T',
        )[0],
        'returnDate': isRoundTrip
            ? _selectedReturnDate?.toIso8601String().split('T')[0]
            : null,
        'passengers': _passengerInfo.toJson(),
        'language': _selectedLanguage,
      };
    }
  }

  // --- Clear Methods ---
  void clearSearch() {
    _selectedFromAirport = null;
    _selectedToAirport = null;
    _selectedDepartureDate = null;
    _selectedReturnDate = null;
    _destinations.clear();
    _notifyListeners();
  }

  void clearAll() {
    clearSearch();
    _passengerInfo = PassengerInfo();
    _tripType = 'one-way';
    _selectedLanguage = 'en';
    _notifyListeners();
  }

  // --- Listener Management ---
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  // --- Validation Methods ---
  bool get isSearchValid {
    if (isMultiCity) {
      return _destinations.isNotEmpty &&
          _destinations.every(
            (d) => d.from.isNotEmpty && d.to.isNotEmpty && d.date.isNotEmpty,
          );
    } else {
      return _selectedFromAirport != null &&
          _selectedToAirport != null &&
          _selectedDepartureDate != null &&
          (isOneWay || (isRoundTrip && _selectedReturnDate != null));
    }
  }

  // --- Debug Methods ---
  void printCurrentState() {
    debugPrint('=== AppService State ===');
    debugPrint('Language: $_selectedLanguage');
    debugPrint('Trip Type: $_tripType');
    debugPrint('From: ${_selectedFromAirport?.id}');
    debugPrint('To: ${_selectedToAirport?.id}');
    debugPrint('Departure: $_selectedDepartureDate');
    debugPrint('Return: $_selectedReturnDate');
    debugPrint('Destinations: ${_destinations.length}');
    for (final dest in _destinations) {
      debugPrint('  - ${dest.from} → ${dest.to} on ${dest.date}');
    }
    debugPrint('Passengers: ${_passengerInfo.toString()}');
    debugPrint('========================');
  }
}
