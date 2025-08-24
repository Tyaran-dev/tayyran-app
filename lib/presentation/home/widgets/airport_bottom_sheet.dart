import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';

class AirportBottomSheet extends StatefulWidget {
  final bool isOrigin;
  final String currentValue;
  final Function(String)? onAirportSelected; // Add this parameter

  const AirportBottomSheet({
    super.key,
    required this.isOrigin,
    required this.currentValue,
    this.onAirportSelected, // Add this parameter
  });

  @override
  _AirportBottomSheetState createState() => _AirportBottomSheetState();
}

class _AirportBottomSheetState extends State<AirportBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> filteredAirports = [];
  bool _isOrigin = true;

  @override
  void initState() {
    super.initState();
    _isOrigin = widget.isOrigin;
    filteredAirports = _getSampleAirports();
    _searchController.addListener(_filterAirports);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  List<String> _getSampleAirports() {
    return [
      'DXB - Dubai International',
      'AUH - Abu Dhabi International',
      'SHJ - Sharjah International',
      'DOH - Hamad International',
      'RUH - King Khalid International',
      'JED - King Abdulaziz International',
      'LHR - London Heathrow',
      'CDG - Paris Charles de Gaulle',
      'JFK - John F. Kennedy International',
    ];
  }

  void _filterAirports() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => filteredAirports = _getSampleAirports());
    } else {
      setState(() {
        filteredAirports = _getSampleAirports()
            .where((airport) => airport.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  void _switchSelection() {
    setState(() {
      _isOrigin = !_isOrigin;
    });
  }

  void _onAirportSelected(String airport) {
    // Use the callback if provided, otherwise use the cubit directly
    if (widget.onAirportSelected != null) {
      widget.onAirportSelected!(airport);
    } else {
      final cubit = context.read<FlightCubit>();
      if (_isOrigin) {
        cubit.setFrom(airport);
      } else {
        cubit.setTo(airport);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Selection type with switch button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isOrigin ? 'Select Origin' : 'Select Destination',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 24),
                onPressed: _switchSelection,
                tooltip: 'Switch between Origin/Destination',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search field
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search airports...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Airports list
          Expanded(
            child: filteredAirports.isEmpty
                ? const Center(
                    child: Text(
                      'No airports found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredAirports.length,
                    itemBuilder: (context, index) {
                      final airport = filteredAirports[index];
                      return ListTile(
                        leading: Icon(
                          _isOrigin ? Icons.flight_takeoff : Icons.flight_land,
                          color: Colors.blue,
                        ),
                        title: Text(
                          airport.split(' - ')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(airport.split(' - ')[1]),
                        onTap: () =>
                            _onAirportSelected(airport), // Use the new method
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
