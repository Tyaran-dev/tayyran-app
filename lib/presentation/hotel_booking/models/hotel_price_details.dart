// lib/data/models/hotel_price_details.dart
class HotelPriceDetails {
  final double totalFare;
  final double totalTax;
  final String currency;
  final List<dynamic> cancelPolicies;
  final List<dynamic> amenities;
  final List<dynamic> rateConditions;
  final String checkInTime;
  final String checkOutTime;

  HotelPriceDetails({
    required this.totalFare,
    required this.totalTax,
    required this.currency,
    required this.cancelPolicies,
    required this.amenities,
    required this.rateConditions,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory HotelPriceDetails.fromJson(Map<String, dynamic> json) {
    final hotelResult = json['HotelResult'][0];
    final room = hotelResult['Rooms'][0];

    // Extract check-in/check-out times from rate conditions
    String checkInTime = '14:00'; // Default
    String checkOutTime = '12:00'; // Default

    final rateConditions = hotelResult['RateConditions'] as List<dynamic>;
    for (final condition in rateConditions) {
      final conditionStr = condition.toString();
      if (conditionStr.contains('CheckIn Time-Begin:')) {
        final match = RegExp(
          r'CheckIn Time-Begin:\s*([\d:]+[APM]*)',
        ).firstMatch(conditionStr);
        if (match != null) checkInTime = match.group(1)!.trim();
      }
      if (conditionStr.contains('CheckOut Time:')) {
        final match = RegExp(
          r'CheckOut Time:\s*([\d:]+[APM]*)',
        ).firstMatch(conditionStr);
        if (match != null) checkOutTime = match.group(1)!.trim();
      }
    }

    return HotelPriceDetails(
      totalFare: (room['TotalFare'] as num).toDouble(),
      totalTax: (room['TotalTax'] as num).toDouble(),
      currency: hotelResult['Currency'],
      cancelPolicies: room['CancelPolicies'] ?? [],
      amenities: room['Amenities'] ?? [],
      rateConditions: rateConditions,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
  }
}
