// lib/presentation/hotel_booking/models/guest_info.dart
class GuestInfo {
  final String title;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phone;

  const GuestInfo({
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.countryCode = '+966',
    this.phone = '',
  });

  GuestInfo copyWith({
    String? title,
    String? firstName,
    String? lastName,
    String? countryCode,
    String? phone,
  }) {
    return GuestInfo(
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
    );
  }

  bool get isValid =>
      title.isNotEmpty && firstName.isNotEmpty && lastName.isNotEmpty;

  bool get isPhoneValid => phone.isNotEmpty;

  String get fullPhone => countryCode + phone;
}
