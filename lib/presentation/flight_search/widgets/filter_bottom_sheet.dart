// filter_bottom_sheet.dart - ENHANCED with airline logos and time icons
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions currentFilters;
  final Function(FilterOptions) onApplyFilters;
  final List<Carrier> availableCarriers; // ADD THIS
  final double minAvailablePrice; // ADD THIS
  final double maxAvailablePrice; // ADD THIS

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
    required this.availableCarriers, // ADD THIS
    required this.minAvailablePrice, // ADD THIS
    required this.maxAvailablePrice, // ADD THIS
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _currentFilters;
  late double _minPriceRange; // ADD THIS
  late double _maxPriceRange; // ADD THIS
  late bool _hasUserChangedPrice; // ADD THIS

  @override
  void initState() {
    super.initState();
    _minPriceRange = widget.minAvailablePrice;
    _maxPriceRange = widget.maxAvailablePrice;
    _hasUserChangedPrice = false; // INITIALLY FALSE

    _currentFilters = FilterOptions(
      departureTimes: List.from(widget.currentFilters.departureTimes),
      stops: List.from(widget.currentFilters.stops),
      airlines: List.from(widget.currentFilters.airlines),
      minPrice: widget.currentFilters.minPrice.clamp(
        _minPriceRange,
        _maxPriceRange,
      ),
      maxPrice: widget.currentFilters.maxPrice.clamp(
        _minPriceRange,
        _maxPriceRange,
      ),
      hasBaggageOnly: widget.currentFilters.hasBaggageOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 42),
              const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Price Range Section
                  _buildPriceRangeSection(),
                  const SizedBox(height: 24),

                  // Flight Stops Section
                  _buildStopsSection(),
                  const SizedBox(height: 24),

                  // Airlines Section
                  _buildAirlinesSection(),
                  const SizedBox(height: 24),

                  // Departure Time Section
                  _buildDepartureTimeSection(),
                  const SizedBox(height: 24),

                  // // Baggage Filter
                  // _buildBaggageSection(),
                  // const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearAllFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GradientButton(
                  height: 52,
                  onPressed: _applyFilters,
                  text: 'Apply Filters',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(AppAssets.currencyIcon, width: 30, height: 30),
          ],
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: RangeValues(
            _currentFilters.minPrice,
            _currentFilters.maxPrice,
          ),
          min: _minPriceRange,
          max: _maxPriceRange,
          divisions: 100,
          activeColor: AppColors.splashBackgroundColorEnd,
          inactiveColor: Colors.grey[300],
          labels: RangeLabels(
            'SAR ${_currentFilters.minPrice.round()}',
            'SAR ${_currentFilters.maxPrice.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _currentFilters.minPrice = values.start;
              _currentFilters.maxPrice = values.end;
              _hasUserChangedPrice = true; // MARK AS CHANGED
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SAR ${_currentFilters.minPrice.round()}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'SAR ${_currentFilters.maxPrice.round()}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Text(
          'Range: SAR ${_minPriceRange.round()} - SAR ${_maxPriceRange.round()}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flight Stops',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StopFilter.values.map((stop) {
            final isSelected = _currentFilters.stops.contains(stop);
            return FilterChip(
              label: Text(
                _getStopFilterLabel(stop),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentFilters.stops.add(stop);
                  } else {
                    _currentFilters.stops.remove(stop);
                  }
                });
              },
              selectedColor: AppColors.splashBackgroundColorEnd,
              backgroundColor: Colors.grey[100],
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.splashBackgroundColorEnd
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAirlinesSection() {
    // USE ACTUAL CARRIERS FROM API
    final airlines = widget.availableCarriers;
    // Debug: Print all airline image URLs
    for (var carrier in airlines) {
      print('Airline: ${carrier.airLineName}, Image URL: ${carrier.image}');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Airlines',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: airlines.map((carrier) {
            final isSelected = _currentFilters.airlines.any(
              (c) => c.airLineCode == carrier.airLineCode,
            );
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Airline logo from API
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: carrier.image,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.airplanemode_active, size: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Airline name from API
                  Text(
                    carrier.airLineName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentFilters.airlines.add(carrier);
                  } else {
                    _currentFilters.airlines.removeWhere(
                      (c) => c.airLineCode == carrier.airLineCode,
                    );
                  }
                });
              },
              selectedColor: AppColors.splashBackgroundColorEnd,
              backgroundColor: Colors.grey[100],
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.splashBackgroundColorEnd
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDepartureTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Departure Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimeChip(
              DepartureTimeFilter.before6am,
              'Before 6am',
              Icons.nightlight_round, // Moon icon for early morning
              Colors.blue,
            ),
            _buildTimeChip(
              DepartureTimeFilter.sixToTwelve,
              '6am - 12pm',
              Icons.wb_sunny, // Sun icon for morning
              Colors.orange,
            ),
            _buildTimeChip(
              DepartureTimeFilter.twelveToSix,
              '12pm - 6pm',
              Icons.wb_sunny_outlined, // Sun outline for afternoon
              Colors.amber,
            ),
            _buildTimeChip(
              DepartureTimeFilter.after6pm,
              'After 6pm',
              Icons.nightlight_round_outlined, // Moon outline for evening
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(
    DepartureTimeFilter time,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = _currentFilters.departureTimes.contains(time);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _currentFilters.departureTimes.add(time);
          } else {
            _currentFilters.departureTimes.remove(time);
          }
        });
      },
      selectedColor: AppColors.splashBackgroundColorEnd,
      backgroundColor: Colors.grey[100],
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? AppColors.splashBackgroundColorEnd
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
  }

  // Widget _buildBaggageSection() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[50],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey[200]!),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.luggage, size: 20, color: Colors.black87),
  //             const SizedBox(width: 8),
  //             const Text(
  //               'Baggage Included',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //           ],
  //         ),
  //         Switch(
  //           value: _currentFilters.hasBaggageOnly,
  //           onChanged: (value) {
  //             setState(() {
  //               _currentFilters.hasBaggageOnly = value;
  //             });
  //           },
  //           activeThumbColor: AppColors.splashBackgroundColorEnd,
  //           activeTrackColor: AppColors.splashBackgroundColorEnd.withValues(
  //             alpha: 0.3,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = FilterOptions(
        minPrice: _minPriceRange, // Reset to actual min
        maxPrice: _maxPriceRange, // Reset to actual max
      );
    });
  }

  void _applyFilters() {
    final newFilters = FilterOptions(
      departureTimes: List.from(_currentFilters.departureTimes),
      stops: List.from(_currentFilters.stops),
      airlines: List.from(_currentFilters.airlines),
      minPrice: _hasUserChangedPrice ? _currentFilters.minPrice : 0,
      maxPrice: _hasUserChangedPrice ? _currentFilters.maxPrice : 10000,
      hasBaggageOnly: _currentFilters.hasBaggageOnly,
    );

    widget.onApplyFilters(newFilters);
    Navigator.pop(context);
  }

  String _getStopFilterLabel(StopFilter stop) {
    switch (stop) {
      case StopFilter.any:
        return 'Any';
      case StopFilter.direct:
        return 'Direct';
      case StopFilter.oneStop:
        return '1 Stop';
      case StopFilter.twoPlusStops:
        return '2+ Stops';
    }
  }
}
