// sort_bottom_sheet.dart - Updated with translations
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';

class SortBottomSheet extends StatefulWidget {
  final Set<SortOption> currentSorts;
  final Function(Set<SortOption>) onSortSelected;

  const SortBottomSheet({
    super.key,
    required this.currentSorts,
    required this.onSortSelected,
  });

  @override
  _SortBottomSheetState createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late Set<SortOption> _selectedSorts;

  @override
  void initState() {
    super.initState();
    _selectedSorts = Set.from(widget.currentSorts);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Text(
                'sort_by'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort options
          Expanded(
            child: ListView(
              children: [
                ...SortOption.values.map((sort) {
                  return _buildSortOption(sort);
                }),
              ],
            ),
          ),

          // Apply button
          const SizedBox(height: 16),
          GradientButton(
            height: 50,
            onPressed: () {
              widget.onSortSelected(_selectedSorts);
              Navigator.pop(context);
            },
            text: 'apply_sort'.tr(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(SortOption sort) {
    final isSelected = _selectedSorts.contains(sort);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.splashBackgroundColorEnd
              : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Icon(
          _getSortIcon(sort),
          color: isSelected
              ? AppColors.splashBackgroundColorEnd
              : Colors.grey[600],
        ),
        title: Text(
          _getSortTitle(sort),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppColors.splashBackgroundColorEnd
                : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          _getSortDescription(sort),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppColors.splashBackgroundColorEnd,
              )
            : null,
        onTap: () {
          setState(() {
            if (_selectedSorts.contains(sort)) {
              _selectedSorts.remove(sort);
            } else {
              _selectedSorts.add(sort);
            }
          });
        },
      ),
    );
  }

  IconData _getSortIcon(SortOption sort) {
    switch (sort) {
      case SortOption.cheapest:
        return Icons.attach_money;
      case SortOption.shortest:
        return Icons.access_time;
      case SortOption.earliestTakeoff:
        return Icons.flight_takeoff;
      case SortOption.earliestArrival:
        return Icons.flight_land;
    }
  }

  String _getSortTitle(SortOption sort) {
    switch (sort) {
      case SortOption.cheapest:
        return 'price_lowest_first'.tr();
      case SortOption.shortest:
        return 'duration_shortest_first'.tr();
      case SortOption.earliestTakeoff:
        return 'departure_earliest_first'.tr();
      case SortOption.earliestArrival:
        return 'arrival_earliest_first'.tr();
    }
  }

  String _getSortDescription(SortOption sort) {
    switch (sort) {
      case SortOption.cheapest:
        return 'sort_by_lowest_price'.tr();
      case SortOption.shortest:
        return 'sort_by_shortest_duration'.tr();
      case SortOption.earliestTakeoff:
        return 'sort_by_earliest_departure'.tr();
      case SortOption.earliestArrival:
        return 'sort_by_earliest_arrival'.tr();
    }
  }
}
