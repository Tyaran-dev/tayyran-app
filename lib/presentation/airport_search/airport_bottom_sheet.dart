import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_state.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/data/models/airport_model.dart';

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
  bool _isOrigin = true;
  late AirportSearchCubit _airportSearchCubit;

  @override
  void initState() {
    super.initState();
    _isOrigin = widget.isOrigin;
    _airportSearchCubit = context.read<AirportSearchCubit>();

    _searchController.addListener(() {
      _airportSearchCubit.searchAirports(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  // void _switchSelection() {
  //   setState(() {
  //     _isOrigin = !_isOrigin;
  //   });
  // }

  void _onAirportSelected(AirportModel airport) {
    if (widget.onAirportSelected != null) {
      widget.onAirportSelected!(airport.displayName);
      Navigator.pop(context, airport.displayName);
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

      // Use widget.isOrigin (the original value) not _isOrigin (the toggled value)
      if (widget.isOrigin) {
        cubit.updateFlightSegment(
          widget.segmentId!,
          airport.displayName, // New from value
          currentSegment.to, // Preserve existing to value
          currentSegment.date, // Preserve existing date value
        );
      } else {
        cubit.updateFlightSegment(
          widget.segmentId!,
          currentSegment.from, // Preserve existing from value
          airport.displayName, // New to value
          currentSegment.date, // Preserve existing date value
        );
      }
    }
    // For regular flight search
    else {
      // Use widget.isOrigin (the original value) not _isOrigin (the toggled value)
      if (widget.isOrigin) {
        cubit.setFrom(airport.displayName);
      } else {
        cubit.setTo(airport.displayName);
      }
    }

    Navigator.pop(context, airport.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocConsumer<AirportSearchCubit, AirportSearchState>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      builder: (context, state) {
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
                  // if (widget.segmentId == null)
                  // //   InkWell(
                  //     onTap: _switchSelection,
                  //     borderRadius: BorderRadius.circular(20),
                  //     child: Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 12,
                  //         vertical: 8,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: _isOrigin
                  //             ? (isDarkMode
                  //                   ? Colors.blue[800]!
                  //                   : Colors.blue[50]!)
                  //             : (isDarkMode
                  //                   ? Colors.green[800]!
                  //                   : Colors.green[50]!),
                  //         borderRadius: BorderRadius.circular(20),
                  //         border: Border.all(
                  //           color: _isOrigin
                  //               ? (isDarkMode
                  //                     ? Colors.blue[400]!
                  //                     : Colors.blue[200]!)
                  //               : (isDarkMode
                  //                     ? Colors.green[400]!
                  //                     : Colors.green[200]!),
                  //           width: 1.5,
                  //         ),
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           Icon(
                  //             _isOrigin
                  //                 ? Icons.flight_takeoff
                  //                 : Icons.flight_land,
                  //             size: 16,
                  //             color: _isOrigin
                  //                 ? (isDarkMode
                  //                       ? Colors.blue[100]!
                  //                       : Colors.blue[600]!)
                  //                 : (isDarkMode
                  //                       ? Colors.green[100]!
                  //                       : Colors.green[600]!),
                  //           ),
                  //           const SizedBox(width: 6),
                  //           Text(
                  //             _isOrigin ? 'Origin' : 'Destination',
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               fontWeight: FontWeight.w600,
                  //               color: _isOrigin
                  //                   ? (isDarkMode
                  //                         ? Colors.blue[100]!
                  //                         : Colors.blue[700]!)
                  //                   : (isDarkMode
                  //                         ? Colors.green[100]!
                  //                         : Colors.green[700]!),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
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
                    fillColor: isDarkMode
                        ? Colors.grey[800]!
                        : Colors.grey[50]!,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                          : (isDarkMode
                                ? Colors.green[200]!
                                : Colors.green[700]!),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOrigin
                          ? 'Selecting origin airport'
                          : 'Selecting destination airport',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isOrigin
                            ? (isDarkMode
                                  ? Colors.blue[200]!
                                  : Colors.blue[700]!)
                            : (isDarkMode
                                  ? Colors.green[200]!
                                  : Colors.green[700]!),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(child: _buildAirportList(state, isDarkMode)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAirportList(AirportSearchState state, bool isDarkMode) {
    if (state is AirportSearchInitial) {
      return _buildInitialState(isDarkMode);
    } else if (state is AirportSearchLoading) {
      return _buildLoadingState(isDarkMode);
    } else if (state is AirportSearchLoaded) {
      return _buildAirportsList(state.airports, isDarkMode);
    } else if (state is AirportSearchError) {
      return _buildErrorState(state.message, isDarkMode);
    } else {
      return Container();
    }
  }

  Widget _buildInitialState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Search for airports',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Type airport name or code',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching airports...',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Error loading airports',
            style: TextStyle(color: Colors.red[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _airportSearchCubit.searchAirports(_searchController.text);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildAirportsList(List<AirportModel> airports, bool isDarkMode) {
    if (airports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplanemode_on, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No airports found',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: airports.length,
      itemBuilder: (context, index) {
        final airport = airports[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onAirportSelected(airport),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isOrigin
                          ? (isDarkMode ? Colors.blue[800]! : Colors.blue[50]!)
                          : (isDarkMode
                                ? Colors.green[800]!
                                : Colors.green[50]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isOrigin ? Icons.flight_takeoff : Icons.flight_land,
                      size: 20,
                      color: _isOrigin
                          ? (isDarkMode ? Colors.blue[100]! : Colors.blue[600]!)
                          : (isDarkMode
                                ? Colors.green[100]!
                                : Colors.green[600]!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          airport.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          airport.text,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Visibility(
                          visible: false,
                          child: Text(
                            '',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _airportSearchCubit.clearSearch();
    super.dispose();
  }
}
