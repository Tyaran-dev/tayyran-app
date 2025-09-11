// filter_sort_chip_bar.dart - UPDATED with airline logos in chips
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/sort_bottom_sheet.dart';

class FilterSortChipBar extends StatelessWidget {
  final Set<SortOption> selectedSorts;
  final FilterOptions filters;
  final Function(Set<SortOption>) onSortChanged;
  final Function() onFilterPressed;
  final Function(SortOption) onSortRemoved;
  final Function(String, dynamic) onFilterRemoved;
  final List<Carrier> availableCarriers; // ADD THIS

  const FilterSortChipBar({
    super.key,
    required this.selectedSorts,
    required this.filters,
    required this.onSortChanged,
    required this.onFilterPressed,
    required this.onSortRemoved,
    required this.onFilterRemoved,
    required this.availableCarriers, // ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = filters.hasActiveFilters;
    final hasActiveSorts = selectedSorts.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filter button
            InkWell(
              onTap: onFilterPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasActiveFilters
                      ? AppColors.splashBackgroundColorEnd.withOpacity(0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasActiveFilters
                        ? AppColors.splashBackgroundColorEnd
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: hasActiveFilters
                          ? AppColors.splashBackgroundColorEnd
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasActiveFilters
                            ? AppColors.splashBackgroundColorEnd
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Sort button
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => SortBottomSheet(
                    currentSorts: selectedSorts,
                    onSortSelected: onSortChanged,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasActiveSorts
                      ? AppColors.splashBackgroundColorEnd.withOpacity(0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasActiveSorts
                        ? AppColors.splashBackgroundColorEnd
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort,
                      size: 16,
                      color: hasActiveSorts
                          ? AppColors.splashBackgroundColorEnd
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sort',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasActiveSorts
                            ? AppColors.splashBackgroundColorEnd
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Active sort chips
            ...selectedSorts.map((sort) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    _getSortLabel(sort),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.splashBackgroundColorEnd,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onSortRemoved(sort),
                ),
              );
            }),

            // Active filter chips
            ..._buildFilterChips(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    if (filters.minPrice > 0 || filters.maxPrice < 10000) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Text(
              'SAR ${filters.minPrice.round()} - ${filters.maxPrice.round()}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
            backgroundColor: Colors.white,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onFilterRemoved('price', null),
          ),
        ),
      );
    }
    // Stops filter
    for (final stop in filters.stops) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Text(
              _getStopLabel(stop),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
            backgroundColor: Colors.white,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onFilterRemoved('stops', stop),
          ),
        ),
      );
    }

    // Airlines filter - UPDATED with logos
    for (final carrier in filters.airlines) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
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
                    image: DecorationImage(
                      image: NetworkImage(carrier.image),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                        // Fallback handled by error widget
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Airline name from API
                Text(
                  carrier.airLineName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onFilterRemoved('airlines', carrier.airLineCode),
          ),
        ),
      );
    }

    // Departure time filter - UPDATED with icons
    for (final time in filters.departureTimes) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Time icon
                Icon(
                  _getTimeIcon(time),
                  size: 14,
                  color: AppColors.splashBackgroundColorEnd,
                ),
                const SizedBox(width: 4),
                // Time label
                Text(
                  _getTimeLabel(time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onFilterRemoved('departureTimes', time),
          ),
        ),
      );
    }

    // Baggage filter - UPDATED with icon
    if (filters.hasBaggageOnly) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Baggage icon
                const Icon(
                  Icons.luggage,
                  size: 14,
                  color: AppColors.splashBackgroundColorEnd,
                ),
                const SizedBox(width: 4),
                // Baggage text
                const Text(
                  'Baggage',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onFilterRemoved('hasBaggageOnly', null),
          ),
        ),
      );
    }

    return chips;
  }

  IconData _getTimeIcon(DepartureTimeFilter time) {
    switch (time) {
      case DepartureTimeFilter.before6am:
        return Icons.nightlight_round; // Moon icon
      case DepartureTimeFilter.sixToTwelve:
        return Icons.wb_sunny; // Sun icon
      case DepartureTimeFilter.twelveToSix:
        return Icons.wb_sunny_outlined; // Sun outline
      case DepartureTimeFilter.after6pm:
        return Icons.nightlight_round_outlined; // Moon outline
    }
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.cheapest:
        return 'Cheapest';
      case SortOption.shortest:
        return 'Shortest';
      case SortOption.earliestTakeoff:
        return 'Earliest Departure';
      case SortOption.earliestArrival:
        return 'Earliest Arrival';
    }
  }

  String _getStopLabel(StopFilter stop) {
    switch (stop) {
      case StopFilter.any:
        return 'Any Stops';
      case StopFilter.direct:
        return 'Direct';
      case StopFilter.oneStop:
        return '1 Stop';
      case StopFilter.twoPlusStops:
        return '2+ Stops';
    }
  }

  String _getTimeLabel(DepartureTimeFilter time) {
    switch (time) {
      case DepartureTimeFilter.before6am:
        return 'Before 6am';
      case DepartureTimeFilter.sixToTwelve:
        return '6am-12pm';
      case DepartureTimeFilter.twelveToSix:
        return '12pm-6pm';
      case DepartureTimeFilter.after6pm:
        return 'After 6pm';
    }
  }
}
