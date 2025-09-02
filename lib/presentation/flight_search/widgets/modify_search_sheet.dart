// modify_search_sheet.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/airport_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/date_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/home/widgets/airport_bottom_sheet.dart';
import 'package:tayyran_app/presentation/home/widgets/passenger_selection_modal.dart';

class ModifySearchSheet extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final FlightSearchCubit cubit;

  const ModifySearchSheet({
    super.key,
    required this.initialData,
    required this.cubit,
  });

  @override
  _ModifySearchSheetState createState() => _ModifySearchSheetState();
}

class _ModifySearchSheetState extends State<ModifySearchSheet> {
  late String _from;
  late String _to;
  late String _departureDate;
  late String _returnDate;
  late int _adults;
  late int _children;
  late int _infants;
  late String _cabinClass;
  late bool _hasReturnDate;
  late bool _showDateError;
  late GlobalKey _returnDateKey;

  @override
  void initState() {
    super.initState();
    // Use the cubit's current state instead of the initial data
    final currentState = widget.cubit.state;
    _from = currentState.searchData['from'] ?? '';
    _to = currentState.searchData['to'] ?? '';
    _departureDate = currentState.searchData['departureDate'] ?? '';
    _returnDate = currentState.searchData['returnDate'] ?? '';
    _adults = currentState.searchData['adults'] is int
        ? currentState.searchData['adults']
        : 1;
    _children = currentState.searchData['children'] is int
        ? currentState.searchData['children']
        : 0;
    _infants = currentState.searchData['infants'] is int
        ? currentState.searchData['infants']
        : 0;
    _cabinClass = currentState.searchData['cabinClass'] is String
        ? currentState.searchData['cabinClass']
        : 'Economy';
    _hasReturnDate = false;
    _showDateError = false;
    _returnDateKey = GlobalKey();
  }

  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final monthNames = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ];
        final day = int.parse(parts[0]);
        final month = monthNames.indexOf(parts[1]) + 1;
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  void _shakeReturnDateField() {
    final context = _returnDateKey.currentContext;
    if (context != null) {
      final animation = AnimationController(
        vsync: Scaffold.of(context),
        duration: const Duration(milliseconds: 300),
      );
      // final curve = CurvedAnimation(
      //   parent: animation,
      //   curve: Curves.elasticOut,
      // );

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animation.reverse();
        }
      });

      animation.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with title and cancel button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              const Text(
                'Modify Search',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form fields container
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // From and To fields with swap button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            AirportTextField(
                              isOrigin: true,
                              label: "From",
                              value: _from,
                              icon: Icons.flight_takeoff,
                              onTap: () => _showAirportBottomSheet(true),
                            ),
                            const SizedBox(height: 12),
                            AirportTextField(
                              isOrigin: false,
                              label: "To",
                              value: _to,
                              icon: Icons.flight_land,
                              onTap: () => _showAirportBottomSheet(false),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppColors.splashBackgroundColorEnd,
                                  side: BorderSide(
                                    color: AppColors.splashBackgroundColorEnd,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.swap_vert,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                onPressed: _swapFromTo,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Departure Date
                    DateTextField(
                      label: "Departure",
                      value: _departureDate,
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context, isDeparture: true),
                    ),
                    const SizedBox(height: 12),

                    // Return Date (if added)
                    if (_hasReturnDate) ...[
                      Stack(
                        key: _returnDateKey,
                        children: [
                          DateTextField(
                            label: "Return",
                            value: _returnDate,
                            icon: Icons.calendar_today,
                            onTap: () =>
                                _selectDate(context, isDeparture: false),
                            hasError: _showDateError,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Row(
                              children: [
                                if (_showDateError)
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _hasReturnDate = false;
                                      _returnDate = '';
                                      _showDateError = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_showDateError)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Return date must be after departure date",
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],

                    // Add Return Date Button
                    if (!_hasReturnDate)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasReturnDate = true;
                              // If departure date is set, set return date to next day
                              if (_departureDate.isNotEmpty) {
                                final departure = _parseDate(_departureDate);
                                final nextDay = departure.add(
                                  const Duration(days: 1),
                                );
                                final monthNames = [
                                  "Jan",
                                  "Feb",
                                  "Mar",
                                  "Apr",
                                  "May",
                                  "Jun",
                                  "Jul",
                                  "Aug",
                                  "Sep",
                                  "Oct",
                                  "Nov",
                                  "Dec",
                                ];
                                _returnDate =
                                    "${nextDay.day}-${monthNames[nextDay.month - 1]}-${nextDay.year}";
                              }
                            });
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Return Date'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.splashBackgroundColorEnd,
                            side: BorderSide(
                              color: AppColors.splashBackgroundColorEnd,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Passenger field
                    _buildPassengerField(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Apply button
          GradientButton(
            onPressed: _applySearch,
            text: 'Apply Changes',
            height: 50,
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 30),
        ],
      ),
    );
  }

  Widget _buildPassengerField() {
    final totalPassengers = _adults + _children + _infants;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.77,
              minChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) => PassengerSelectionModal(
                adults: _adults,
                children: _children,
                infants: _infants,
                cabinClass: _cabinClass,
                onPassengersChanged: (adults, children, infants) {
                  setState(() {
                    _adults = adults;
                    _children = children;
                    _infants = infants;
                  });
                },
                onCabinClassChanged: (cabinClass) {
                  setState(() {
                    _cabinClass = cabinClass;
                  });
                },
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.people, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$totalPassengers Passenger${totalPassengers > 1 ? 's' : ''} • $_cabinClass",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$_adults Adult${_adults != 1 ? 's' : ''}, "
                    "$_children Child${_children != 1 ? 'ren' : ''}, "
                    "$_infants Infant${_infants != 1 ? 's' : ''}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isDeparture,
  }) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    // Set initial date based on existing selection
    if (isDeparture && _departureDate.isNotEmpty) {
      initialDate = _parseDate(_departureDate);
    } else if (!isDeparture && _returnDate.isNotEmpty) {
      initialDate = _parseDate(_returnDate);

      // For return date, ensure firstDate is at least the day after departure
      if (_departureDate.isNotEmpty) {
        final departureDate = _parseDate(_departureDate);
        firstDate = departureDate.add(const Duration(days: 1));

        // Ensure initialDate is not before firstDate
        if (initialDate.isBefore(firstDate)) {
          initialDate = firstDate;
        }
      }
    }

    // Ensure initialDate is not before firstDate
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.splashBackgroundColorEnd,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.splashBackgroundColorEnd,
              ),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      final formattedDate =
          "${picked.day}-${monthNames[picked.month - 1]}-${picked.year}";

      setState(() {
        if (isDeparture) {
          _departureDate = formattedDate;
          // If return date is before new departure date, clear it and show error
          if (_hasReturnDate && _returnDate.isNotEmpty) {
            final returnDate = _parseDate(_returnDate);
            if (returnDate.isBefore(picked)) {
              _returnDate = '';
              _showDateError = true;
              _shakeReturnDateField();
            } else {
              _showDateError = false;
            }
          }
        } else {
          _returnDate = formattedDate;
          // Validate return date is after departure
          if (_departureDate.isNotEmpty) {
            final departureDate = _parseDate(_departureDate);
            if (picked.isBefore(departureDate.add(const Duration(days: 1)))) {
              _showDateError = true;
              _shakeReturnDateField();
            } else {
              _showDateError = false;
            }
          }
        }
      });
    }
  }

  void _showAirportBottomSheet(bool isOrigin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => AirportBottomSheet(
            isOrigin: isOrigin,
            currentValue: isOrigin ? _from : _to,
            onAirportSelected: (airport) {
              setState(() {
                if (isOrigin) {
                  _from = airport;
                } else {
                  _to = airport;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  void _swapFromTo() {
    setState(() {
      final temp = _from;
      _from = _to;
      _to = temp;
    });
  }

  void _applySearch() {
    // Validate dates
    if (_hasReturnDate && _returnDate.isNotEmpty) {
      final departure = _parseDate(_departureDate);
      final returnDate = _parseDate(_returnDate);

      if (returnDate.isBefore(departure.add(const Duration(days: 1)))) {
        setState(() {
          _showDateError = true;
        });
        _shakeReturnDateField();
        return;
      }
    }

    final newSearchData = {
      'from': _from,
      'to': _to,
      'departureDate': _departureDate,
      'returnDate': _hasReturnDate ? _returnDate : '',
      'adults': _adults,
      'children': _children,
      'infants': _infants,
      'cabinClass': _cabinClass,
      'tripType': _hasReturnDate ? 'round' : 'oneway',
    };

    widget.cubit.loadFlights(newSearchData);
    Navigator.pop(context);
  }
}
