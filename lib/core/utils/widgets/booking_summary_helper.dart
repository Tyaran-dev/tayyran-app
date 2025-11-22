// lib/presentation/hotel_booking/utils/booking_summary_helper.dart
class BookingSummaryHelper {
  static int calculateNights(String checkIn, String checkOut) {
    try {
      final checkInDate = DateTime.parse(checkIn);
      final checkOutDate = DateTime.parse(checkOut);
      return checkOutDate.difference(checkInDate).inDays;
    } catch (e) {
      return 1;
    }
  }

  static List<int> calculateGuestsPerRoom(int totalAdults, int numberOfRooms) {
    final guestsPerRoom = <int>[];
    var remainingAdults = totalAdults;

    for (int i = 0; i < numberOfRooms; i++) {
      if (i == numberOfRooms - 1) {
        guestsPerRoom.add(remainingAdults);
      } else {
        final guestsInThisRoom = (remainingAdults / (numberOfRooms - i)).ceil();
        guestsPerRoom.add(guestsInThisRoom);
        remainingAdults -= guestsInThisRoom;
      }
    }

    return guestsPerRoom;
  }

  static int getGuestsForRoom(List<int> guestsPerRoom, int roomIndex) {
    return roomIndex < guestsPerRoom.length ? guestsPerRoom[roomIndex] : 0;
  }
}
