// filter_sort_chip_bar.dart - UPDATED with airline logos in chips
import 'package:easy_localization/easy_localization.dart';
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
  final List<Carrier> availableCarriers;

  const FilterSortChipBar({
    super.key,
    required this.selectedSorts,
    required this.filters,
    required this.onSortChanged,
    required this.onFilterPressed,
    required this.onSortRemoved,
    required this.onFilterRemoved,
    required this.availableCarriers,
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
                      ? AppColors.splashBackgroundColorEnd.withValues(
                          alpha: 0.2,
                        )
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
                      'filter'.tr(),
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
                      ? AppColors.splashBackgroundColorEnd.withValues(
                          alpha: 0.2,
                        )
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
                      'sort'.tr(),
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
                // Airline name with Arabic support - FIXED
                Builder(
                  builder: (context) {
                    final isArabic = context.locale.languageCode == 'ar';
                    final airlineName = isArabic
                        ? (carrier.airlineNameAr.isNotEmpty == true
                              ? carrier.airlineNameAr
                              : carrier.airLineName)
                        : carrier.airLineName;

                    return Text(
                      airlineName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.splashBackgroundColorEnd,
                      ),
                    );
                  },
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
        return 'cheapest'.tr();
      case SortOption.shortest:
        return 'shortest'.tr();
      case SortOption.earliestTakeoff:
        return 'earliest_departure'.tr();
      case SortOption.earliestArrival:
        return 'earliest_arrival'.tr();
    }
  }

  String _getStopLabel(StopFilter stop) {
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

  String _getTimeLabel(DepartureTimeFilter time) {
    switch (time) {
      case DepartureTimeFilter.before6am:
        return 'before_6am'.tr();
      case DepartureTimeFilter.sixToTwelve:
        return '6am_to_12pm'.tr();
      case DepartureTimeFilter.twelveToSix:
        return '12pm_to_6pm'.tr();
      case DepartureTimeFilter.after6pm:
        return 'after_6pm'.tr();
    }
  }
}
