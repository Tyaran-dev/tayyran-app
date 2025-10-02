// lib/presentation/passenger_info/widgets/passenger_card.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';

class PassengerCard extends StatelessWidget {
  final Passenger passenger;
  final int index;
  final VoidCallback onEdit;

  const PassengerCard({
    super.key,
    required this.passenger,
    required this.index,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        passenger.firstName.isNotEmpty && passenger.lastName.isNotEmpty;

    IconData getIconForPassengerType() {
      switch (passenger.type) {
        case TravelerType.ADULT:
          return Icons.person;
        case TravelerType.CHILD:
          return Icons.child_care;
        case TravelerType.INFANT:
          return Icons.child_friendly;
      }
    }

    Color getColorForPassengerType() {
      switch (passenger.type) {
        case TravelerType.ADULT:
          return AppColors.splashBackgroundColorEnd;
        case TravelerType.CHILD:
          return Colors.orange;
        case TravelerType.INFANT:
          return Colors.pink;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? getColorForPassengerType().withOpacity(0.3)
              : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? getColorForPassengerType().withOpacity(0.1)
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? getIconForPassengerType() : Icons.person_add,
            color: isCompleted ? getColorForPassengerType() : Colors.grey[600],
          ),
        ),
        title: Text(
          isCompleted
              ? '${passenger.title} ${passenger.firstName} ${passenger.lastName}'
              : 'Passenger ${index + 1} - ${passenger.type.displayName}',
          style: TextStyle(
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isCompleted ? Colors.black : Colors.grey[600],
          ),
        ),
        subtitle: isCompleted
            ? Text(
                passenger.passportNumber.isNotEmpty
                    ? 'Passport: ${passenger.passportNumber}'
                    : 'Tap to complete details',
                style: const TextStyle(fontSize: 12),
              )
            : Text(
                'Tap to add details',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
        trailing: IconButton(
          icon: Icon(
            isCompleted ? Icons.edit : Icons.add,
            color: getColorForPassengerType(),
          ),
          onPressed: onEdit,
        ),
        onTap: onEdit,
      ),
    );
  }
}
