// lib/core/network/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.tayyaran.com';
  static const String sendEmailBaseUrl = 'https://tayyran.com';
  // static const String baseUrl = 'https://test.tayyaran.com';

  // endpoints
  static const String getAirport = '/airports/getairport';
  static const String searchFlights = "/flights/flight-search";
  static const String flightPricing = "/flights/flight-pricing";
  static const String saveFlight = "/payment/saveData";
  static const String getPaymentStatus = "/payment/bookingStatus";
  static const String sendConfirmationEmail = "/api/flights-email";

  //hotels
  static const String hotelSearch = "/hotels/HotelsSearch";
  static const String hotelDetails = "/hotels/HotelDetails";

  static const String getCities = '/hotels/CityList';
  // static String getUserById(int id) => '/users/$id';
}
