// filter_bottom_sheet.dart - UPDATED with Arabic airline names
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final List<Carrier> availableCarriers;
  final double minAvailablePrice;
  final double maxAvailablePrice;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
    required this.availableCarriers,
    required this.minAvailablePrice,
    required this.maxAvailablePrice,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _currentFilters;
  late double _minPriceRange;
  late double _maxPriceRange;
  late bool _hasUserChangedPrice;

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

  String _getAirlineName(Carrier carrier) {
    final isArabic = context.locale.languageCode == 'ar';
    if (isArabic) {
      return carrier.airlineNameAr;
    }
    return carrier.airLineName;
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
              Text(
                'filter'.tr(),
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
                  child: Text(
                    'clear_all'.tr(),
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
                  text: 'apply_filters'.tr(),
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
            Text(
              'price_range'.tr(),
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
            '${'sar'.tr()} ${_currentFilters.minPrice.round()}',
            '${'sar'.tr()} ${_currentFilters.maxPrice.round()}',
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
              '${'sar'.tr()} ${_currentFilters.minPrice.round()}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              '${'sar'.tr()} ${_currentFilters.maxPrice.round()}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Text(
          'price_range_hint'
              .tr()
              .replaceAll('{min}', _minPriceRange.round().toString())
              .replaceAll('{max}', _maxPriceRange.round().toString()),
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
        Text(
          'flight_stops'.tr(),
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
        Text(
          'airlines'.tr(),
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
                  // Airline name with Arabic support
                  Text(
                    _getAirlineName(carrier),
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
        Text(
          'departure_time'.tr(),
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
              'before_6am'.tr(),
              Icons.nightlight_round, // Moon icon for early morning
              Colors.blue,
            ),
            _buildTimeChip(
              DepartureTimeFilter.sixToTwelve,
              '6am_to_12pm'.tr(),
              Icons.wb_sunny, // Sun icon for morning
              Colors.orange,
            ),
            _buildTimeChip(
              DepartureTimeFilter.twelveToSix,
              '12pm_to_6pm'.tr(),
              Icons.wb_sunny_outlined, // Sun outline for afternoon
              Colors.amber,
            ),
            _buildTimeChip(
              DepartureTimeFilter.after6pm,
              'after_6pm'.tr(),
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
        return 'any_stops'.tr();
      case StopFilter.direct:
        return 'direct'.tr();
      case StopFilter.oneStop:
        return 'one_stop'.tr();
      case StopFilter.twoPlusStops:
        return 'two_plus_stops'.tr();
    }
  }
}
