// lib/presentation/hotel_details/widgets/room_type_group.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/room_selection_card.dart';

class RoomTypeGroup extends StatefulWidget {
  final String roomType;
  final List<HotelRoom> rooms;
  final String currency;
  final HotelRoom? selectedRoom;
  final Function(HotelRoom) onSelectRoom;
  final Function(HotelRoom) onViewCancellationPolicy;
  final double percentageCommission;

  const RoomTypeGroup({
    super.key,
    required this.roomType,
    required this.rooms,
    required this.currency,
    required this.selectedRoom,
    required this.onSelectRoom,
    required this.onViewCancellationPolicy,
    required this.percentageCommission,
  });

  @override
  State<RoomTypeGroup> createState() => _RoomTypeGroupState();
}

class _RoomTypeGroupState extends State<RoomTypeGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Room Type Header with Gradient
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.splashBackgroundColorStart,
                      AppColors.splashBackgroundColorEnd,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.roomType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.rooms.length} ${widget.rooms.length == 1 ? 'option' : 'options'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // Room Options (Collapsible)
            if (_isExpanded)
              Container(
                color: Colors.white,
                child: Column(
                  children: widget.rooms
                      .map(
                        (room) => Padding(
                          padding: const EdgeInsets.all(16).copyWith(top: 0),
                          child: RoomSelectionCard(
                            room: room,
                            currency: widget.currency,
                            isSelected:
                                widget.selectedRoom?.bookingCode ==
                                room.bookingCode,
                            onSelect: () => widget.onSelectRoom(room),
                            onViewCancellationPolicy: () =>
                                widget.onViewCancellationPolicy(room),
                            percentageCommission: widget.percentageCommission,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
