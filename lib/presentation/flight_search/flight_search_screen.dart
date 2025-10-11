import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/filter_bottom_sheet.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/flight_ticket_card.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/filter_sort_chip_bar.dart';

class FlightSearchScreen extends StatefulWidget {
  final Map<String, dynamic> searchData;

  const FlightSearchScreen({super.key, required this.searchData});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<FlightSearchCubit>();
      // Only load if we don't have data or it's different
      if (cubit.state.originalSearchData.isEmpty) {
        cubit.loadFlights(widget.searchData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        height: 120,
        title: 'Flight Results',
        showBackButton: true,
        isFlightResults: true,
      ),
      body: BlocBuilder<FlightSearchCubit, FlightSearchState>(
        builder: (context, state) {
          return _buildContentArea(context, state);
        },
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, FlightSearchState state) {
    final cubit = context.read<FlightSearchCubit>();

    return Column(
      children: [
        // Filter & Sort Chip Bar - Only show when we have results or loading
        if (state.tickets.isNotEmpty || state.isLoading)
          FilterSortChipBar(
            selectedSorts: state.selectedSorts,
            filters: state.filters,
            availableCarriers: state.availableCarriers,
            onSortChanged: (sorts) => cubit.applySorts(sorts),
            onFilterPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => FilterBottomSheet(
                  currentFilters: state.filters,
                  onApplyFilters: (filters) {
                    cubit.applyFilters(filters);
                  },
                  availableCarriers: state.availableCarriers,
                  minAvailablePrice: state.minTicketPrice,
                  maxAvailablePrice: state.maxTicketPrice,
                ),
              );
            },
            onSortRemoved: (sort) {
              final newSorts = Set<SortOption>.from(state.selectedSorts);
              newSorts.remove(sort);
              cubit.applySorts(newSorts);
            },
            onFilterRemoved: (filterType, value) {
              cubit.removeFilter(filterType, value);
            },
          ),

        // Results count - Only show when we have results
        if (state.tickets.isNotEmpty && !state.isLoading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.filteredTickets.length} flights found',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Show current search summary
                if (state.searchData.isNotEmpty)
                  Text(
                    _buildSearchSummary(state.searchData),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

        // Results or Loading/Error
        Expanded(child: _buildResults(context, state)),
      ],
    );
  }

  String _buildSearchSummary(Map<String, dynamic> searchData) {
    if (searchData.isEmpty) return 'Searching...';

    final tripType = searchData['flightType'] ?? 'oneway';

    if (tripType == 'multi') {
      final multiCityRoutes =
          searchData['multiCityRoutes'] as List<dynamic>? ?? [];
      if (multiCityRoutes.isNotEmpty) {
        final segments = multiCityRoutes.map((route) {
          final from = route['from']?.split(' - ')[0] ?? '';
          final to = route['to']?.split(' - ')[0] ?? '';
          return '$from→$to';
        }).toList();
        return 'Multi: ${segments.join(' • ')}';
      }
      return 'Multi-City Journey';
    } else {
      final from = searchData['from']?.toString().split(' - ')[0] ?? '';
      final to = searchData['to']?.toString().split(' - ')[0] ?? '';
      final departure = searchData['departureDate']?.toString() ?? '';
      final returnDate = searchData['returnDate']?.toString() ?? '';

      if (returnDate.isNotEmpty) {
        return '$from ↔ $to • $departure';
      } else {
        return '$from → $to • $departure';
      }
    }
  }

  Widget _buildResults(BuildContext context, FlightSearchState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.errorMessage != null) {
      return _buildErrorState(context, state);
    }

    if (state.filteredTickets.isEmpty) {
      return _buildNoResultsState(context, state);
    }

    return _buildFlightList(state);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.splashBackgroundColorEnd,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching for flights...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, FlightSearchState state) {
    final cubit = context.read<FlightSearchCubit>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Try Again',
              height: 50,
              width: MediaQuery.of(context).size.width * 0.6,
              onPressed: () {
                cubit.loadFlights(state.originalSearchData);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Modify Search',
                style: TextStyle(
                  color: AppColors.splashBackgroundColorEnd,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, FlightSearchState state) {
    final cubit = context.read<FlightSearchCubit>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No flights found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchData['flightType'] == 'multi'
                  ? 'Try modifying your multi-city route or search again'
                  : 'Try modifying your search criteria or search again',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Retry button
            GradientButton(
              text: 'Search Again',
              height: 50,
              width: MediaQuery.of(context).size.width * 0.6,
              onPressed: () {
                cubit.loadFlights(state.originalSearchData);
              },
            ),
            const SizedBox(height: 16),

            // Modify search button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Modify Search',
                style: TextStyle(
                  color: AppColors.splashBackgroundColorEnd,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightList(FlightSearchState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredTickets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FlightTicketCard(ticket: state.filteredTickets[index]),
        );
      },
    );
  }
}
