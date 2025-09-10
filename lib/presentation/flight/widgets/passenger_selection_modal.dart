import 'package:flutter/material.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
// import 'package:tayyran_app/core/utils/custom_button.dart';

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
  late String _cabinClass;

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _children = widget.children;
    _infants = widget.infants;
    _cabinClass = widget.cabinClass;
  }

  void _updatePassengers() {
    widget.onPassengersChanged(_adults, _children, _infants);
  }

  @override
  Widget build(BuildContext context) {
    final totalPassengers = _adults + _children + _infants;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
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
            SizedBox(height: 16),
            Text(
              "Passengers & Cabin Class",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Passengers Section with border and shadow
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Adults
                  _buildPassengerType(
                    title: "Adults",
                    subtitle: "Age 12+",
                    count: _adults,
                    onDecrement: () {
                      if (_adults > 1) {
                        setState(() {
                          _adults--;
                          if (_infants > _adults) {
                            _infants = _adults;
                          }
                          if (_adults == 0) {
                            _adults = 1;
                          }
                          if (_infants == 0 && _adults == 1) {
                            _infants = 1;
                          }
                          _updatePassengers();
                        });
                      }
                    },
                    onIncrement: () {
                      if (_adults < 9 && totalPassengers < 9) {
                        setState(() {
                          _adults++;
                          _updatePassengers();
                        });
                      }
                    },
                  ),
                  Divider(height: 20),

                  // Children
                  _buildPassengerType(
                    title: "Children",
                    subtitle: "Age 2-11",
                    count: _children,
                    onDecrement: () {
                      if (_children > 0) {
                        setState(() {
                          _children--;
                          _updatePassengers();
                        });
                      }
                    },
                    onIncrement: () {
                      if (_children < 8 && totalPassengers < 9) {
                        setState(() {
                          _children++;
                          _updatePassengers();
                        });
                      }
                    },
                  ),
                  Divider(height: 20),

                  // Infants
                  _buildPassengerType(
                    title: "Infants",
                    subtitle: "Under 2 years",
                    count: _infants,
                    onDecrement: () {
                      if (_infants > 0) {
                        setState(() {
                          _infants--;
                          _updatePassengers();
                        });
                      }
                    },
                    onIncrement: () {
                      if (_infants < _adults &&
                          _infants < 8 &&
                          totalPassengers < 9) {
                        setState(() {
                          _infants++;
                          _updatePassengers();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Cabin Class Section with border and shadow
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cabin Class",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                  Column(
                    children: [
                      _buildCabinClassRadio(
                        'Economy',
                        'The standard seating option',
                      ),
                      _buildCabinClassRadio(
                        'Premium Economy',
                        'More legroom and amenities',
                      ),
                      _buildCabinClassRadio(
                        'Business',
                        'Premium service and comfort',
                      ),
                      _buildCabinClassRadio(
                        'First',
                        'The most luxurious experience',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, size: 28),
              onPressed: onDecrement,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                "$count",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, size: 28),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCabinClassRadio(String value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _cabinClass = value;
          });
          widget.onCabinClassChanged(_cabinClass);
        },
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _cabinClass,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _cabinClass = newValue;
                  });
                  widget.onCabinClassChanged(_cabinClass);
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontSize: 15)),
                  SizedBox(height: 2),
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
