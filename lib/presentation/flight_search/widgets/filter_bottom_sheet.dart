// filter_bottom_sheet.dart - ENHANCED with airline logos and time icons
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions currentFilters;
  final Function(FilterOptions) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    // Create a deep copy to ensure we're working with mutable lists
    _currentFilters = FilterOptions(
      departureTimes: List.from(widget.currentFilters.departureTimes),
      stops: List.from(widget.currentFilters.stops),
      airlines: List.from(widget.currentFilters.airlines),
      minPrice: widget.currentFilters.minPrice,
      maxPrice: widget.currentFilters.maxPrice,
      hasBaggageOnly: widget.currentFilters.hasBaggageOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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

                  // Baggage Filter
                  _buildBaggageSection(),
                  const SizedBox(height: 32),
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
          min: 0,
          max: 10000,
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
    final airlines = [
      _Airline('Flynas', 'https://logo.clearbit.com/flynas.com'),
      _Airline('Flyadeal', 'https://logo.clearbit.com/flyadeal.com'),
      _Airline('Saudia', 'https://logo.clearbit.com/saudia.com'),
      _Airline('Hahn Air', 'https://logo.clearbit.com/hahnair.com'),
      _Airline('Egypt Air', 'https://logo.clearbit.com/egyptair.com'),
    ];

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
          children: airlines.map((airline) {
            final isSelected = _currentFilters.airlines.contains(airline.name);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Airline logo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: NetworkImage(airline.logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Airline name
                  Text(
                    airline.name,
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
                    _currentFilters.airlines.add(airline.name);
                  } else {
                    _currentFilters.airlines.remove(airline.name);
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

  Widget _buildBaggageSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.luggage, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              const Text(
                'Baggage Included',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Switch(
            value: _currentFilters.hasBaggageOnly,
            onChanged: (value) {
              setState(() {
                _currentFilters.hasBaggageOnly = value;
              });
            },
            activeThumbColor: AppColors.splashBackgroundColorEnd,
            activeTrackColor: AppColors.splashBackgroundColorEnd.withOpacity(
              0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = FilterOptions();
    });
  }

  void _applyFilters() {
    // Create a new instance to ensure we're passing mutable lists
    final newFilters = FilterOptions(
      departureTimes: List.from(_currentFilters.departureTimes),
      stops: List.from(_currentFilters.stops),
      airlines: List.from(_currentFilters.airlines),
      minPrice: _currentFilters.minPrice,
      maxPrice: _currentFilters.maxPrice,
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

// Helper class for airline data
class _Airline {
  final String name;
  final String logoUrl;

  _Airline(this.name, this.logoUrl);
}
