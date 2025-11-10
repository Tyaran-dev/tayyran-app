import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/presentation/hotels/model/hotel_room.dart';

class RoomSelectionModal extends StatefulWidget {
  final List<HotelRoom> rooms;
  final Function(List<HotelRoom>) onRoomsChanged;

  const RoomSelectionModal({
    super.key,
    required this.rooms,
    required this.onRoomsChanged,
  });

  @override
  State<RoomSelectionModal> createState() => _RoomSelectionModalState();
}

class _RoomSelectionModalState extends State<RoomSelectionModal> {
  late List<HotelRoom> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = List<HotelRoom>.from(widget.rooms);
  }

  void _updateRoom(int index, HotelRoom room) {
    setState(() {
      _rooms[index] = room;
    });
    widget.onRoomsChanged(_rooms);
  }

  void _addRoom() {
    if (_rooms.length < 8) {
      setState(() {
        _rooms.add(const HotelRoom());
      });
      widget.onRoomsChanged(_rooms);
    }
  }

  void _removeRoom(int index) {
    if (_rooms.length > 1) {
      setState(() {
        _rooms.removeAt(index);
      });
      widget.onRoomsChanged(_rooms);
    }
  }

  void _showAgePicker(BuildContext context, int roomIndex, int childIndex) {
    final currentAge = _rooms[roomIndex].childrenAges[childIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AgePickerBottomSheet(
        initialAge: currentAge,
        onAgeSelected: (age) {
          final newAges = List<int>.from(_rooms[roomIndex].childrenAges);
          newAges[childIndex] = age;
          _updateRoom(
            roomIndex,
            _rooms[roomIndex].copyWith(childrenAges: newAges),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'hotels.rooms_guests'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rooms List
          Expanded(
            child: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                return _buildRoomCard(index, _rooms[index]);
              },
            ),
          ),

          // Add Room Button
          if (_rooms.length < 8)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: OutlinedButton.icon(
                onPressed: _addRoom,
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'hotels.add_another_room'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.splashBackgroundColorEnd,
                  side: BorderSide(color: AppColors.splashBackgroundColorEnd),
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'hotels.apply'.tr(),
              height: 56,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRoomCard(int index, HotelRoom room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header with Remove Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'hotels.room'.tr()} ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_rooms.length > 1)
                InkWell(
                  onTap: () => _removeRoom(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade50,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Adults Selection
          _buildCounterRow(
            title: 'hotels.adults'.tr(),
            subtitle: 'hotels.age_18_plus'.tr(),
            value: room.adults,
            min: 1,
            max: 4,
            onChanged: (value) {
              _updateRoom(index, room.copyWith(adults: value));
            },
          ),
          const SizedBox(height: 20),

          // Children Selection
          _buildCounterRow(
            title: 'hotels.children'.tr(),
            subtitle: 'hotels.ages_0_17'.tr(),
            value: room.children,
            min: 0,
            max: 3,
            onChanged: (value) {
              // Change default age from 0 to 1
              final newChildrenAges = List<int>.filled(
                value,
                1,
              ); // Changed from 0 to 1
              // Copy existing ages if available
              for (int i = 0; i < value && i < room.childrenAges.length; i++) {
                newChildrenAges[i] = room.childrenAges[i];
              }
              _updateRoom(
                index,
                room.copyWith(children: value, childrenAges: newChildrenAges),
              );
            },
          ),

          // Children Age Selection
          if (room.children > 0) ...[
            const SizedBox(height: 16),
            Text(
              'hotels.children_ages'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(room.children, (childIndex) {
                final age = room.childrenAges[childIndex];
                return _buildAgeChip(
                  childIndex: childIndex,
                  age: age,
                  onTap: () => _showAgePicker(context, index, childIndex),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  isEnabled: value > min,
                  onPressed: () => onChanged(value - 1),
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add,
                  isEnabled: value < max,
                  onPressed: () => onChanged(value + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeChip({
    required int childIndex,
    required int age,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.splashBackgroundColorEnd.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.splashBackgroundColorEnd.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'hotels.child'.tr()} ${childIndex + 1}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color: AppColors.splashBackgroundColorEnd.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            Text(
              '$age ${'hotels.years'.tr()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _CounterButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isEnabled
            ? AppColors.splashBackgroundColorEnd.withOpacity(0.1)
            : Colors.grey.shade100,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 18,
              color: isEnabled
                  ? AppColors.splashBackgroundColorEnd
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}

class AgePickerBottomSheet extends StatefulWidget {
  final int initialAge;
  final Function(int) onAgeSelected;

  const AgePickerBottomSheet({
    super.key,
    required this.initialAge,
    required this.onAgeSelected,
  });

  @override
  State<AgePickerBottomSheet> createState() => _AgePickerBottomSheetState();
}

class _AgePickerBottomSheetState extends State<AgePickerBottomSheet> {
  late FixedExtentScrollController _scrollController;
  late int _selectedAge;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.initialAge;
    // Adjust initial item since ages now start from 1 (index 0 = age 1)
    _scrollController = FixedExtentScrollController(
      initialItem:
          _selectedAge - 1, // Subtract 1 because index 0 now represents age 1
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'hotels.select_age'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Picker
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                // Center indicator
                Center(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.splashBackgroundColorEnd.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Wheel picker - Changed to generate from 1 to 17
                Row(
                  children: [
                    Expanded(
                      child: ListWheelScrollView(
                        controller: _scrollController,
                        itemExtent: 40,
                        perspective: 0.01,
                        diameterRatio: 1.2,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedAge =
                                index + 1; // Add 1 to get actual age (1-17)
                          });
                        },
                        children: List.generate(17, (index) {
                          final age = index + 1; // Start from 1 instead of 0
                          return Center(
                            child: Text(
                              '$age ${'hotels.years'.tr()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: _selectedAge == age
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedAge == age
                                    ? AppColors.splashBackgroundColorEnd
                                    : Colors.grey,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Select Button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              height: 50,
              text: 'hotels.select_exact_age'.tr(),
              onPressed: () => widget.onAgeSelected(_selectedAge),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
