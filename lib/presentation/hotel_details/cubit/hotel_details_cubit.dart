// lib/presentation/hotel_details/cubit/hotel_details_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/cancellation_policies_bottom_sheet.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/facilities_bottom_sheet.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/hotel_description_bottom_sheet.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/image_gallery_bottom_sheet.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/price_details_bottom_sheet.dart';

part 'hotel_details_state.dart';

class HotelDetailsCubit extends Cubit<HotelDetailsState> {
  HotelDetailsCubit({
    required HotelData hotel,
    required Map<String, dynamic> searchParams,
  }) : super(HotelDetailsLoading()) {
    _loadHotelData(hotel, searchParams);
  }

  Future<void> _loadHotelData(
    HotelData hotel,
    Map<String, dynamic> searchParams,
  ) async {
    try {
      // Add artificial delay to show shimmer
      await Future.delayed(const Duration(milliseconds: 1500));

      // Process room types and group by names
      final groupedRooms = _groupRoomsByName(hotel.rooms);

      // Limit images to 20
      final limitedImages = _limitImages(hotel.images, hotel.image);

      final processedHotel = hotel.copyWith(
        rooms: groupedRooms,
        images: limitedImages,
      );

      emit(
        HotelDetailsLoaded(hotel: processedHotel, searchParams: searchParams),
      );
    } catch (error) {
      // If there's an error, still emit loaded state with original data
      emit(HotelDetailsLoaded(hotel: hotel, searchParams: searchParams));
    }
  }

  List<HotelRoom> _groupRoomsByName(List<HotelRoom> rooms) {
    final roomGroups = <String, List<HotelRoom>>{};

    for (final room in rooms) {
      final roomName = room.displayName;
      if (!roomGroups.containsKey(roomName)) {
        roomGroups[roomName] = [];
      }
      roomGroups[roomName]!.add(room);
    }

    // Sort rooms within each group by price
    final result = <HotelRoom>[];
    roomGroups.forEach((name, roomList) {
      roomList.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
      result.addAll(roomList);
    });

    return result;
  }

  List<String> _limitImages(List<String> images, String primaryImage) {
    final allImages = images.isNotEmpty ? images : [primaryImage];
    return allImages.length > 20 ? allImages.sublist(0, 20) : allImages;
  }

  void selectRoom(HotelRoom room) {
    if (state is HotelDetailsLoaded) {
      final currentState = state as HotelDetailsLoaded;
      emit(currentState.copyWith(selectedRoom: room));
    }
  }

  void clearSelection() {
    if (state is HotelDetailsLoaded) {
      final currentState = state as HotelDetailsLoaded;
      emit(currentState.copyWith(selectedRoom: null));
    }
  }

  void showAllImages(BuildContext context) {
    if (state is HotelDetailsLoaded) {
      final currentState = state as HotelDetailsLoaded;
      final allImages = currentState.hotel.images.isNotEmpty
          ? currentState.hotel.images
          : [currentState.hotel.image];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageGalleryBottomSheet(images: allImages),
      );
    }
  }

  void showAllFacilities(BuildContext context) {
    if (state is HotelDetailsLoaded) {
      final currentState = state as HotelDetailsLoaded;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => FacilitiesBottomSheet(
          facilities: currentState.hotel.hotelFacilities,
        ),
      );
    }
  }

  void showHotelDescription(BuildContext context) {
    if (state is HotelDetailsLoaded) {
      final currentState = state as HotelDetailsLoaded;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => HotelDescriptionBottomSheet(
          description: currentState.hotel.description,
          hotelName: currentState.hotel.hotelName,
        ),
      );
    }
  }

  void showPriceDetails(BuildContext context, HotelRoom room) {
    if (state is HotelDetailsLoaded) {
      final currentState = state as HotelDetailsLoaded;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PriceDetailsBottomSheet(
          room: room,
          percentageCommission: currentState.hotel.percentageCommission,
        ),
      );
    }
  }

  void showCancellationPolicies(BuildContext context, HotelRoom room) {
    if (state is HotelDetailsLoaded) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => CancellationPoliciesBottomSheet(room: room),
      );
    }
  }
}
