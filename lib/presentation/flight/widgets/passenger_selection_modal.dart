import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';

class PassengerSelectionModal extends StatefulWidget {
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;
  final Function(int, int, int) onPassengersChanged;
  final Function(String) onCabinClassChanged;

  const PassengerSelectionModal({
    super.key,
    required this.adults,
    required this.children,
    required this.infants,
    required this.cabinClass,
    required this.onPassengersChanged,
    required this.onCabinClassChanged,
  });

  @override
  _PassengerSelectionModalState createState() =>
      _PassengerSelectionModalState();
}

class _PassengerSelectionModalState extends State<PassengerSelectionModal> {
  late int _adults;
  late int _children;
  late int _infants;
  late String _currentCabinClass;

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _children = widget.children;
    _infants = widget.infants;
    _currentCabinClass = widget.cabinClass;
  }

  @override
  void didUpdateWidget(PassengerSelectionModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adults != widget.adults) {
      setState(() {
        _adults = widget.adults;
      });
    }
    if (oldWidget.children != widget.children) {
      setState(() {
        _children = widget.children;
      });
    }
    if (oldWidget.infants != widget.infants) {
      setState(() {
        _infants = widget.infants;
      });
    }
    if (oldWidget.cabinClass != widget.cabinClass) {
      setState(() {
        _currentCabinClass = widget.cabinClass;
      });
    }
  }

  void _updatePassengerCount(String type, int change) {
    setState(() {
      switch (type) {
        case 'adults':
          final newAdults = _adults + change;
          if (newAdults >= 1 &&
              newAdults <= 9 &&
              _getTotalPassengers() + change <= 9) {
            _adults = newAdults;
            // Ensure infants don't exceed adults
            if (_infants > _adults) {
              _infants = _adults;
            }
          }
          break;
        case 'children':
          final newChildren = _children + change;
          if (newChildren >= 0 &&
              newChildren <= 8 &&
              _getTotalPassengers() + change <= 9) {
            _children = newChildren;
          }
          break;
        case 'infants':
          final newInfants = _infants + change;
          if (newInfants >= 0 &&
              newInfants <= _adults &&
              _getTotalPassengers() + change <= 9) {
            _infants = newInfants;
          }
          break;
      }
    });

    // Notify parent about the change
    widget.onPassengersChanged(_adults, _children, _infants);
  }

  int _getTotalPassengers() {
    return _adults + _children + _infants;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Passengers & Cabin Class",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Passengers Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPassengerType(
                    title: "Adults",
                    subtitle: "Age 12+",
                    count: _adults,
                    onDecrement: () => _updatePassengerCount('adults', -1),
                    onIncrement: () => _updatePassengerCount('adults', 1),
                  ),
                  const Divider(height: 20),
                  _buildPassengerType(
                    title: "Children",
                    subtitle: "Age 2-11",
                    count: _children,
                    onDecrement: () => _updatePassengerCount('children', -1),
                    onIncrement: () => _updatePassengerCount('children', 1),
                  ),
                  const Divider(height: 20),
                  _buildPassengerType(
                    title: "Infants",
                    subtitle: "Under 2 years",
                    count: _infants,
                    onDecrement: () => _updatePassengerCount('infants', -1),
                    onIncrement: () => _updatePassengerCount('infants', 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cabin Class Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cabin Class",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _buildCabinClassOption(
                        'Economy',
                        'The standard seating option',
                      ),
                      _buildCabinClassOption(
                        'Premium Economy',
                        'More legroom and amenities',
                      ),
                      _buildCabinClassOption(
                        'Business',
                        'Premium service and comfort',
                      ),
                      _buildCabinClassOption(
                        'First',
                        'The most luxurious experience',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            GradientButton(
              text: 'Confirm',
              height: 50,
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerType({
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                size: 28,
                color: onDecrement == _disabledDecrement
                    ? Colors.grey[400]
                    : null,
              ),
              onPressed: onDecrement,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                "$count",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                size: 28,
                color: onIncrement == _disabledIncrement
                    ? Colors.grey[400]
                    : null,
              ),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods to disable buttons when limits are reached
  VoidCallback get _disabledDecrement => () {};
  VoidCallback get _disabledIncrement => () {};

  Widget _buildCabinClassOption(String displayValue, String description) {
    // Convert display value to backend value for comparison
    final String backendValue = displayValue.toCabinClassBackendValue;
    final bool isSelected = _currentCabinClass == backendValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          // Update local state for immediate UI feedback
          setState(() {
            _currentCabinClass = backendValue;
          });
          // Notify parent about the change
          widget.onCabinClassChanged(backendValue);
        },
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.splashBackgroundColorEnd
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayValue, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
