import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';

class AirportBottomSheet extends StatefulWidget {
  final bool isOrigin;
  final String currentValue;
  final Function(String)? onAirportSelected;
  final String? segmentId;

  const AirportBottomSheet({
    super.key,
    required this.isOrigin,
    required this.currentValue,
    this.onAirportSelected,
    this.segmentId,
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
    if (widget.onAirportSelected != null) {
      widget.onAirportSelected!(airport);
      Navigator.pop(context);
      return;
    }

    final cubit = context.read<FlightCubit>();

    // For multi-city segments
    if (widget.segmentId != null) {
      // Get the current segment to preserve existing values
      final currentSegment = cubit.state.flightSegments.firstWhere(
        (segment) => segment.id == widget.segmentId,
        orElse: () => FlightSegment(id: '', from: '', to: '', date: ''),
      );

      if (_isOrigin) {
        cubit.updateFlightSegment(
          widget.segmentId!,
          airport, // New from value
          currentSegment.to, // Preserve existing to value
          currentSegment.date, // Preserve existing date value
        );
      } else {
        cubit.updateFlightSegment(
          widget.segmentId!,
          currentSegment.from, // Preserve existing from value
          airport, // New to value
          currentSegment.date, // Preserve existing date value
        );
      }
    }
    // For regular flight search
    else {
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOrigin
                        ? 'Select Origin Airport'
                        : 'Select Destination Airport',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isOrigin
                        ? 'Where will you depart from?'
                        : 'Where will you arrive?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (widget.segmentId == null)
                InkWell(
                  onTap: _switchSelection,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isOrigin
                          ? (isDarkMode ? Colors.blue[800]! : Colors.blue[50]!)
                          : (isDarkMode
                                ? Colors.green[800]!
                                : Colors.green[50]!),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isOrigin
                            ? (isDarkMode
                                  ? Colors.blue[400]!
                                  : Colors.blue[200]!)
                            : (isDarkMode
                                  ? Colors.green[400]!
                                  : Colors.green[200]!),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isOrigin ? Icons.flight_takeoff : Icons.flight_land,
                          size: 16,
                          color: _isOrigin
                              ? (isDarkMode
                                    ? Colors.blue[100]!
                                    : Colors.blue[600]!)
                              : (isDarkMode
                                    ? Colors.green[100]!
                                    : Colors.green[600]!),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isOrigin ? 'Origin' : 'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isOrigin
                                ? (isDarkMode
                                      ? Colors.blue[100]!
                                      : Colors.blue[700]!)
                                : (isDarkMode
                                      ? Colors.green[100]!
                                      : Colors.green[700]!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: _isOrigin
                    ? 'Search origin airport...'
                    : 'Search destination airport...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800]! : Colors.grey[50]!,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOrigin
                  ? (isDarkMode ? Colors.blue[900]! : Colors.blue[50]!)
                  : (isDarkMode ? Colors.green[900]! : Colors.green[50]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: _isOrigin
                      ? (isDarkMode ? Colors.blue[200]! : Colors.blue[700]!)
                      : (isDarkMode ? Colors.green[200]! : Colors.green[700]!),
                ),
                const SizedBox(width: 8),
                Text(
                  _isOrigin
                      ? 'Selecting origin airport'
                      : 'Selecting destination airport',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOrigin
                        ? (isDarkMode ? Colors.blue[200]! : Colors.blue[700]!)
                        : (isDarkMode
                              ? Colors.green[200]!
                              : Colors.green[700]!),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: filteredAirports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airplanemode_on,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No airports found',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredAirports.length,
                    itemBuilder: (context, index) {
                      final airport = filteredAirports[index];
                      final code = airport.split(' - ')[0];
                      final name = airport.split(' - ')[1];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onAirportSelected(airport),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _isOrigin
                                        ? (isDarkMode
                                              ? Colors.blue[800]!
                                              : Colors.blue[50]!)
                                        : (isDarkMode
                                              ? Colors.green[800]!
                                              : Colors.green[50]!),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _isOrigin
                                        ? Icons.flight_takeoff
                                        : Icons.flight_land,
                                    size: 20,
                                    color: _isOrigin
                                        ? (isDarkMode
                                              ? Colors.blue[100]!
                                              : Colors.blue[600]!)
                                        : (isDarkMode
                                              ? Colors.green[100]!
                                              : Colors.green[600]!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        code,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
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
